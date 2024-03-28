%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "prepare the wsl installation for export (remove all sensitive files)" \
    --alt "--prepare-export" \
    --alt "-e" \
    --variable-name "PREPARE_EXPORT" \
    --function-name optionExportFunction
)
options+=(
  optionExportFunction
)
%
export PREPARE_EXPORT
