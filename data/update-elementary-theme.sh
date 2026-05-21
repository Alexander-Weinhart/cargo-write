#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stylesheet_dir="${repo_root}/third_party/elementary-stylesheet"
sass_bin="${stylesheet_dir}/node_modules/.bin/sass"
output_dir="${repo_root}/data/elementary"
variants=(banana blueberry bubblegum cocoa grape latte lime mint orange slate strawberry)

if [[ ! -x "${sass_bin}" ]]; then
    echo "Missing ${sass_bin}. Run: (cd third_party/elementary-stylesheet && npm install --no-save sass)" >&2
    exit 1
fi

mkdir -p "${output_dir}"
rm -f "${output_dir}"/*.css

for variant in "${variants[@]}"; do
    "${sass_bin}" "${stylesheet_dir}/src/gtk-4.0/variants/${variant}.scss" "${output_dir}/${variant}.css"
    "${sass_bin}" "${stylesheet_dir}/src/gtk-4.0/variants/${variant}-dark.scss" "${output_dir}/${variant}-dark.css"
done

rm -f "${output_dir}"/*.css.map
