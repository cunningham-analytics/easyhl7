#!/usr/bin/env python3

from pathlib import Path


PROJECT_ROOT = Path.cwd()
PIPELINES_FILE = PROJECT_ROOT / "easyhl7_pipelines.yml"


MANIFEST = """{
  "pipelines": {
    "lab_results": {
      "message_type": "ORU_R01",
      "version": "2.5.1",
      "model_path": "lab_results/staging",
      "model_prefix": "lab_results",
      "message_ref": "lab_results__raw"
    }
  }
}
"""


def main() -> None:
    if not (PROJECT_ROOT / "dbt_project.yml").exists():
        raise FileNotFoundError(
            "Run this command from the root of your dbt project."
        )

    if PIPELINES_FILE.exists():
        print(
            f"SKIP   {PIPELINES_FILE.name} already exists."
        )
        return

    PIPELINES_FILE.write_text(MANIFEST)

    print(
        f"CREATE {PIPELINES_FILE.name}"
    )


if __name__ == "__main__":
    main()