#!/usr/bin/env python3

import argparse
import ast
import json
import re
from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = Path.cwd()

CONFIG_ROOT = PACKAGE_ROOT / "macros" / "configs"
MODELS_ROOT = PROJECT_ROOT / "models"
PIPELINES_FILE = PROJECT_ROOT / "easyhl7_pipelines.yml"


def version_slug(version: str) -> str:
    return f"v{version.replace('.', '_')}"


def version_tuple(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


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


def load_pipelines() -> dict:
    if not PIPELINES_FILE.exists():
        raise FileNotFoundError(
            f"Could not find {PIPELINES_FILE.name} in "
            f"{PROJECT_ROOT}. Create it with "
            f"easyhl7_create_pipeline_manifest."
        )

    try:
        with PIPELINES_FILE.open() as file:
            manifest = json.load(file)
    except json.JSONDecodeError as exc:
        raise ValueError(
            f"Could not parse {PIPELINES_FILE.name}. "
            f"The EasyHL7 pipeline manifest must use "
            f"JSON-compatible YAML syntax. "
            f"Error at line {exc.lineno}, column {exc.colno}: "
            f"{exc.msg}"
        ) from exc

    if not isinstance(manifest, dict):
        raise ValueError(
            f"{PIPELINES_FILE.name} must contain a dictionary."
        )

    pipelines = manifest.get("pipelines")

    if not isinstance(pipelines, dict) or not pipelines:
        raise ValueError(
            f"{PIPELINES_FILE.name} must contain a non-empty "
            f"'pipelines' dictionary."
        )

    return pipelines


def validate_pipeline(
    pipeline_name: str,
    pipeline: dict,
) -> None:
    if not isinstance(pipeline, dict):
        raise ValueError(
            f"Pipeline '{pipeline_name}' must contain a dictionary."
        )

    required_fields = [
        "message_type",
        "version",
        "model_path",
        "model_prefix",
        "message_ref",
    ]

    missing = [
        field
        for field in required_fields
        if field not in pipeline or pipeline[field] in (None, "")
    ]

    if missing:
        raise ValueError(
            f"Pipeline '{pipeline_name}' is missing required "
            f"field(s): {', '.join(missing)}"
        )


def get_groups(node: dict) -> list[dict]:
    groups = []

    for child in node.get("children", []):
        if child.get("type") == "group":
            groups.append(child)
            groups.extend(get_groups(child))

    return groups


def model_name(
    model_prefix: str,
    message_type: str,
    suffix: str,
    version: str,
) -> str:
    return (
        f"{model_prefix.lower()}__"
        f"{message_type.lower()}__"
        f"{suffix.lower()}__"
        f"{version_slug(version)}"
    )


def segments_sql(
    message_ref: str,
) -> str:
    return f"""{{{{ config(materialized='table') }}}}

{{% set args = {{
    'message_ref': '{message_ref}',
    'message_column': 'message'
}} %}}

{{{{ easyhl7.split_segments(args) }}}}
"""


def hierarchy_sql(
    version: str,
    message_type: str,
    model_prefix: str,
) -> str:
    segment_ref = model_name(
        model_prefix,
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
    model_prefix: str,
    group_name: str,
) -> str:
    hierarchy_ref = model_name(
        model_prefix,
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
    pipeline_name: str,
    pipeline: dict,
) -> None:
    validate_pipeline(
        pipeline_name,
        pipeline,
    )

    version = str(pipeline["version"])
    message_type = str(
        pipeline["message_type"]
    ).upper()
    model_path = str(pipeline["model_path"])
    model_prefix = str(
        pipeline["model_prefix"]
    ).lower()
    message_ref = str(
        pipeline["message_ref"]
    )

    print()
    print(f"PIPELINE {pipeline_name}")

    config_path = find_config_file(
        version,
        message_type,
    )

    config = load_config(config_path)

    output_dir = MODELS_ROOT / model_path

    output_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    segments_name = model_name(
        model_prefix,
        message_type,
        "segments",
        version,
    )

    hierarchy_name = model_name(
        model_prefix,
        message_type,
        "hierarchy",
        version,
    )

    write_model(
        output_dir / f"{segments_name}.sql",
        segments_sql(
            message_ref,
        ),
    )

    write_model(
        output_dir / f"{hierarchy_name}.sql",
        hierarchy_sql(
            version,
            message_type,
            model_prefix,
        ),
    )

    for group in get_groups(config):
        group_name = group["name"]
        group_slug = group_name.lower()

        name = model_name(
            model_prefix,
            message_type,
            group_slug,
            version,
        )

        write_model(
            output_dir / f"{name}.sql",
            group_sql(
                version,
                message_type,
                model_prefix,
                group_name,
            ),
        )


def generate_all(
    pipelines: dict,
) -> None:
    for pipeline_name, pipeline in pipelines.items():
        generate_pipeline(
            pipeline_name,
            pipeline,
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Generate EasyHL7 dbt pipelines from "
            "easyhl7_pipelines.yml."
        )
    )

    group = parser.add_mutually_exclusive_group(
        required=True
    )

    group.add_argument(
        "pipeline",
        nargs="?",
        help=(
            "Pipeline name defined in "
            "easyhl7_pipelines.yml."
        ),
    )

    group.add_argument(
        "--all",
        action="store_true",
        help=(
            "Generate every pipeline defined in "
            "easyhl7_pipelines.yml."
        ),
    )

    args = parser.parse_args()

    pipelines = load_pipelines()

    if args.all:
        generate_all(pipelines)
        return

    if args.pipeline not in pipelines:
        available = ", ".join(pipelines.keys())

        raise ValueError(
            f"Pipeline '{args.pipeline}' was not found in "
            f"{PIPELINES_FILE.name}. "
            f"Available pipelines: {available}"
        )

    generate_pipeline(
        args.pipeline,
        pipelines[args.pipeline],
    )


if __name__ == "__main__":
    main()