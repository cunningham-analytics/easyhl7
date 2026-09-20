#!/usr/bin/env bash

set -e

if [[ "$SHELL" == *"zsh"* ]]; then
    PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    if [[ -f "$HOME/.bashrc" ]]; then
        PROFILE="$HOME/.bashrc"
    else
        PROFILE="$HOME/.bash_profile"
    fi
else
    echo "EasyHL7 error: unsupported shell: $SHELL"
    exit 1
fi

START_MARKER="# >>> EasyHL7 commands >>>"
END_MARKER="# <<< EasyHL7 commands <<<"

if grep -qF "$START_MARKER" "$PROFILE" 2>/dev/null; then
    awk -v start="$START_MARKER" -v end="$END_MARKER" '
        $0 == start { skip = 1; next }
        $0 == end { skip = 0; next }
        !skip { print }
    ' "$PROFILE" > "${PROFILE}.easyhl7_tmp"

    mv "${PROFILE}.easyhl7_tmp" "$PROFILE"
fi

if grep -q '^easyhl7_gen_pipeline() {' "$PROFILE" 2>/dev/null; then
    awk '
        /^easyhl7_gen_pipeline\(\) \{$/ {
            skip = 1
            next
        }

        skip && /^}$/ {
            skip = 0
            next
        }

        !skip {
            print
        }
    ' "$PROFILE" > "${PROFILE}.easyhl7_tmp"

    mv "${PROFILE}.easyhl7_tmp" "$PROFILE"
fi

cat >> "$PROFILE" <<'EOF'

# >>> EasyHL7 commands >>>

easyhl7_create_pipeline_manifest() {
    if [[ $# -ne 0 ]]; then
        echo "Usage: easyhl7_create_pipeline_manifest"
        return 1
    fi

    if [[ ! -f "dbt_project.yml" ]]; then
        echo "EasyHL7 error: run this command from the root of your dbt project."
        return 1
    fi

    if [[ ! -f "dbt_packages/easyhl7/utils/create_pipeline_manifest.py" ]]; then
        echo "EasyHL7 error: EasyHL7 was not found in dbt_packages. Run dbt deps first."
        return 1
    fi

    ./dbt_packages/easyhl7/utils/create_pipeline_manifest.py
}

easyhl7_gen_pipeline() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: easyhl7_gen_pipeline <pipeline>"
        echo "       easyhl7_gen_pipeline --all"
        return 1
    fi

    if [[ ! -f "dbt_project.yml" ]]; then
        echo "EasyHL7 error: run this command from the root of your dbt project."
        return 1
    fi

    if [[ ! -f "easyhl7_pipelines.yml" ]]; then
        echo "EasyHL7 error: easyhl7_pipelines.yml was not found."
        echo "Run easyhl7_create_pipeline_manifest first."
        return 1
    fi

    if [[ ! -f "dbt_packages/easyhl7/utils/generate_pipeline.py" ]]; then
        echo "EasyHL7 error: EasyHL7 was not found in dbt_packages. Run dbt deps first."
        return 1
    fi

    ./dbt_packages/easyhl7/utils/generate_pipeline.py "$1"
}

# <<< EasyHL7 commands <<<
EOF

echo "EasyHL7 commands installed in $PROFILE"
echo
echo "Reload your shell with:"
echo "  source $PROFILE"
echo
echo "Available commands:"
echo "  easyhl7_create_pipeline_manifest"
echo "  easyhl7_gen_pipeline <pipeline>"
echo "  easyhl7_gen_pipeline --all"