#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Themes.css is now maintained directly in-tree."
echo "To refresh the vendored elementary GTK4 theme variants, run:"
echo "  ${script_dir}/update-elementary-theme.sh"
