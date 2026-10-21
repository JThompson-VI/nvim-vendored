#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
command -v node >/dev/null
command -v npm >/dev/null
node -e 'if (Number(process.versions.node.split(".")[0]) < 20) { console.error("Node.js 20 or newer is required"); process.exit(1); }'
if [ "$#" -gt 1 ]; then
  echo "Usage: sh tools/vue/install.sh [Neovim-data-directory]" >&2
  exit 1
fi
if [ "$#" -eq 1 ]; then
  data_dir=$1
else
  data_dir=$(NVIM_LOG_FILE=/dev/null nvim --headless -u NONE -i NONE -n \
    '+lua io.stdout:write(vim.fn.stdpath("data"))' '+qa!')
fi
for profile in legacy modern; do
  target=$data_dir/vue-tools/$profile
  mkdir -p "$target"
  cp "$script_dir/$profile/package.json" "$script_dir/$profile/package-lock.json" "$target/"
  npm ci --prefix "$target" --ignore-scripts --no-audit --no-fund
done
echo "Vue tools installed in $data_dir/vue-tools. Restart Neovim."
