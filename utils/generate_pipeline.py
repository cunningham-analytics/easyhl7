#!/usr/bin/env python3

import argparse
import ast
import re
from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = Path.cwd()

CONFIG_ROOT = PACKAGE_ROOT / "macros" / "configs"
MODELS_ROOT = PROJECT_ROOT / "models"


def version_slug(version: str) -> str:
    return f"v{version.replace('.', '_')}"


def version_tuple(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def message_parts(message_type: str) -> tuple[str, str]:
    parts = message_type.lower().split("_", 1)

    if len(parts) != 2:
        raise ValueError(
            f"Expected message type like ORM_O01, got {message_type}"
        )

    return parts[0], parts[1]


def find_config_file(version: str, message_type: str) -> Path:
    message_type = message_type.upper()
    requested_version = version_tuple(version)

    pattern = re.compile(
        rf"{{%\s*macro\s+config_v(\d+(?:_\d+)*)_"
        rf"{re.escape(message_type)}\s*\(\s*\)\s*%}}"
    )

    candidates = []

    for path in CONFIG_ROOT.rglob("*.sql"):
        text = path.read_text()

        for match in pattern.finditer(text):
            config_version = tuple(
                int(part)
                for part in match.group(1).split("_")
            )

            if config_version <= requested_version:
                candidates.append(
                    (config_version, path)
                )

    if not candidates:
        raise FileNotFoundError(
            f"Could not find a compatible config for "
            f"{message_type} version {version} under {CONFIG_ROOT}"
        )

    config_version, config_path = max(
        candidates,
        key=lambda candidate: candidate[0],
    )

    resolved_version = ".".join(
        str(part) for part in config_version
    )

    print(
        f"CONFIG {message_type} {version} "
        f"-> {resolved_version} "
        f"({config_path.relative_to(PACKAGE_ROOT)})"
    )

    return config_path


def load_config(path: Path) -> dict:
    text = path.read_text()

    match = re.search(
        r"{%\s*set\s+config\s*=\s*(.*?)\s*%}",
        text,
        re.DOTALL,
    )

    if not match:
        raise ValueError(
            f"Could not find config dictionary in {path}"
        )

    config_text = match.group(1)

    config_text = re.sub(r"\bnone\b", "None", config_text)
    config_text = re.sub(r"\btrue\b", "True", config_text)
    config_text = re.sub(r"\bfalse\b", "False", config_text)

    return ast.literal_eval(config_text)


def get_groups(node: dict) -> list[dict]:
    groups = []

    for child in node.get("children", []):
        if child.get("type") == "group":
            groups.append(child)
            groups.extend(get_groups(child))

    return groups


def model_name(
    message_type: str,
    suffix: str,
    version: str,
) -> str:
    return (
        f"{message_type.lower()}__{suffix}__"
        f"{version_slug(version)}"
    )


def segments_sql(
    version: str,
    message_type: str,
) -> str:
    seed = (
        f"{message_type.lower()}_sample__"
        f"{version_slug(version)}"
    )

    return f"""{{{{ config(materialized='table') }}}}

{{% set args = {{
    'message_ref': '{seed}',
    'message_column': 'message'
}} %}}

{{{{ easyhl7.split_segments(args) }}}}
"""


def hierarchy_sql(
    version: str,
    message_type: str,
) -> str:
    segment_ref = model_name(
        message_type,
        "segments",
        version,
    )

    return f"""{{{{ config(materialized='table') }}}}

{{% set args = {{
    'segment_ref': '{segment_ref}',
    'version': '{version}',
    'message_type': '{message_type.upper()}'
}} %}}

{{{{ easyhl7.apply_config(args) }}}}
"""


def group_sql(
    version: str,
    message_type: str,
    group_name: str,
) -> str:
    hierarchy_ref = model_name(
        message_type,
        "hierarchy",
        version,
    )

    return f"""{{{{ config(materialized='table') }}}}

{{% set args = {{
    'hierarchy_ref': '{hierarchy_ref}',
    'version': '{version}',
    'message_type': '{message_type.upper()}',
    'group': '{group_name}'
}} %}}

{{{{ easyhl7.parse_group(args) }}}}
"""


def write_model(path: Path, sql: str) -> None:
    if path.exists():
        print(
            f"SKIP   "
            f"{path.relative_to(PROJECT_ROOT)}"
        )
        return

    path.write_text(sql)

    print(
        f"CREATE "
        f"{path.relative_to(PROJECT_ROOT)}"
    )


def generate_pipeline(
    version: str,
    message_type: str,
    model_path: str | None = None,
) -> None:
    message_type = message_type.upper()
    slug = version_slug(version)
    message, trigger = message_parts(message_type)

    config_path = find_config_file(
        version,
        message_type,
    )

    config = load_config(config_path)

    if model_path:
        output_dir = PROJECT_ROOT / model_path
    else:
        output_dir = (
            MODELS_ROOT
            / slug
            / message
            / trigger
        )

    output_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    segments_name = model_name(
        message_type,
        "segments",
        version,
    )

    hierarchy_name = model_name(
        message_type,
        "hierarchy",
        version,
    )

    write_model(
        output_dir / f"{segments_name}.sql",
        segments_sql(
            version,
            message_type,
        ),
    )

    write_model(
        output_dir / f"{hierarchy_name}.sql",
        hierarchy_sql(
            version,
            message_type,
        ),
    )

    for group in get_groups(config):
        group_name = group["name"]
        group_slug = group_name.lower()

        name = model_name(
            message_type,
            group_slug,
            version,
        )

        write_model(
            output_dir / f"{name}.sql",
            group_sql(
                version,
                message_type,
                group_name,
            ),
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Generate an EasyHL7 dbt pipeline."
        )
    )

    parser.add_argument(
        "--version",
        required=True,
        help="HL7 version, e.g. 2.4",
    )

    parser.add_argument(
        "--message",
        required=True,
        help="HL7 message type, e.g. ORM_O01",
    )

    parser.add_argument(
        "--model-path",
        required=False,
        help=(
            "Output path for generated models, "
            "relative to the dbt project root. "
            "If omitted, uses "
            "models/<version>/<message>/<trigger>."
        ),
    )

    args = parser.parse_args()

    generate_pipeline(
        version=args.version,
        message_type=args.message,
        model_path=args.model_path,
    )


if __name__ == "__main__":
    main()