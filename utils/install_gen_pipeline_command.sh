#!/usr/bin/env bash

set -e

FUNCTION='
easyhl7_gen_pipeline() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: easyhl7_gen_pipeline <message> <version> <model_path>"
        echo "Example: easyhl7_gen_pipeline ORU_R01 2.5.1 lab_results"
        return 1
    fi

    if [[ ! -f "dbt_project.yml" ]]; then
        echo "EasyHL7 error: run this command from the root of your dbt project."
        return 1
    fi

    if [[ ! -f "dbt_packages/easyhl7/utils/generate_pipeline.py" ]]; then
        echo "EasyHL7 error: EasyHL7 was not found in dbt_packages. Run dbt deps first."
        return 1
    fi

    local message="$1"
    local version="$2"
    local model_path="$3"

    ./dbt_packages/easyhl7/utils/generate_pipeline.py \
        --message "$message" \
        --version "$version" \
        --model-path "models/$model_path"
}
'

case "$SHELL" in
    */zsh)
        PROFILE="$HOME/.zshrc"
        ;;
    */bash)
        if [[ -f "$HOME/.bashrc" ]]; then
            PROFILE="$HOME/.bashrc"
        else
            PROFILE="$HOME/.bash_profile"
        fi
        ;;
    *)
        echo "EasyHL7 error: unsupported shell: $SHELL"
        echo "Automatic command installation currently supports zsh and bash."
        exit 1
        ;;
esac

if grep -q "easyhl7_gen_pipeline()" "$PROFILE" 2>/dev/null; then
    echo "easyhl7_gen_pipeline is already configured in $PROFILE"
    exit 0
fi

printf "\n%s\n" "$FUNCTION" >> "$PROFILE"

echo "Installed easyhl7_gen_pipeline in $PROFILE"
echo
echo "Reload your shell configuration with:"
echo "source $PROFILE"
echo
echo "Then generate a pipeline with:"
echo "easyhl7_gen_pipeline ORU_R01 2.5.1 lab_results"