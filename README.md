# Neovim configuration

Lua configuration using locally vendored plugins and Lazy.nvim. Requires
**Neovim 0.12 or newer**; tested on macOS with Neovim 0.12.6 and Tree-sitter
CLI 0.27.1. The same configuration targets Ubuntu 22.04 or newer; Ubuntu
installation steps below have not been executed in this macOS environment.

## Installation and upgrades

### macOS (Homebrew)

For a new installation:

```sh
brew install neovim tree-sitter-cli ripgrep fd
xcode-select --install  # if the C compiler / make are missing
```

For an existing Homebrew installation, retain old packages while upgrading:

```sh
HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade neovim
HOMEBREW_NO_INSTALL_CLEANUP=1 brew install tree-sitter-cli
nvim --version
tree-sitter --version
```

### Ubuntu 22.04 or newer

Use the official versioned archive to install the same Neovim release without
replacing Ubuntu's system packages. First check your release and architecture:

```sh
cat /etc/os-release
uname -m
ldd --version
sudo apt update
sudo apt install build-essential curl tar gzip git ripgrep fd-find inotify-tools
```

Download the archive for your architecture and place it in your home directory:

```sh
case "$(uname -m)" in
  x86_64) nvim_arch=x86_64 ;;
  aarch64|arm64) nvim_arch=arm64 ;;
  *) echo "Unsupported architecture"; exit 1 ;;
esac
curl -fL "https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-${nvim_arch}.tar.gz" \
  -o /tmp/nvim-0.12.6.tar.gz
mkdir -p "$HOME/.local/opt/nvim-0.12.6" "$HOME/.local/bin"
tar -xzf /tmp/nvim-0.12.6.tar.gz --strip-components=1 -C "$HOME/.local/opt/nvim-0.12.6"
export PATH="$HOME/.local/opt/nvim-0.12.6/bin:$HOME/.local/bin:$PATH"
command -v nvim
nvim --version
```

Add that PATH export to your shell configuration (for example `~/.bashrc`).
Keep the entire extracted directory together: Neovim needs its matching
runtime files. If the executable reports a missing GLIBC version, use a
compatible distribution or build the v0.12.6 tag from source following the
[official build instructions](https://github.com/neovim/neovim/blob/v0.12.6/BUILD.md).
Official archives and AppImages are available on the
[release page](https://github.com/neovim/neovim/releases/tag/v0.12.6).

Install the **Tree-sitter CLI**, separately from Neovim's Tree-sitter library.
The Ubuntu apt version may be too old; this installs the pinned upstream binary:

```sh
case "$(uname -m)" in
  x86_64) ts_arch=x64 ;;
  aarch64|arm64) ts_arch=arm64 ;;
  *) echo "Unsupported architecture"; exit 1 ;;
esac
curl -fL "https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.1/tree-sitter-linux-${ts_arch}.gz" \
  -o /tmp/tree-sitter-0.27.1.gz
gzip -dc /tmp/tree-sitter-0.27.1.gz > "$HOME/.local/bin/tree-sitter"
chmod u+x "$HOME/.local/bin/tree-sitter"
tree-sitter --version
```

Use a CLI version >=0.26.1, installed through a package manager or an official
binary, rather than npm. If the binary cannot run on your system, a Rust
toolchain provides another installation method:
`cargo install tree-sitter-cli --version 0.27.1 --locked` (add `~/.cargo/bin`
to PATH).

### Complete setup on each machine

Place this repository at `~/.config/nvim`. From that directory:

```sh
make -C vendor/telescope-fzf-native.nvim
sh tools/vue/install.sh  # Vue/Nuxt: requires Node.js >=20 and npm
nvim
```

Inside Neovim, run `:TSInstallConfigured` and restart. Install your language
servers separately as described below; Vue/Nuxt profiles have their own
installer. Typical Ubuntu options include `sudo apt install clangd` for C/C++,
`npm install -g pyright typescript-language-server typescript@5.9.3` for
Python/TypeScript (use a user-managed Node installation), and the Go command
below for gopls. Install `lua-language-server` separately using its
[official installation instructions](https://luals.github.io/#neovim-install).
Check each executable with `command -v`; servers not installed are skipped.

Compile Telescope's sorter and Tree-sitter parsers on **each** OS/architecture;
do not copy macOS libraries to Ubuntu. The `fd-find` Ubuntu package provides
`fdfind`, which Telescope supports. Clipboard integration on Ubuntu additionally
needs a provider such as `wl-clipboard` on Wayland or `xclip` on X11.
`inotify-tools` supplies `inotifywait` for efficient LSP file watching on Linux.

### Recovery from the 0.11 migration

The migration keeps the old `stdpath("data")/treesitter` directory and installs
new parsers into `treesitter-0.12`. A copy of the pre-upgrade config and parsers
is stored on this Mac in `~/.local/share/nvim/backups/pre-0.12-20261021/`.
Restore the config archive **together with Neovim 0.11** if rolling back;
the current configuration intentionally refuses to run on 0.11.

Homebrew's retained 0.11 keg needs its old Tree-sitter library, whose `opt`
symlink now points to the newer version. To verify the old executable without
changing the active installation:

```sh
DYLD_LIBRARY_PATH=/opt/homebrew/Cellar/tree-sitter/0.25.3/lib \
  /opt/homebrew/Cellar/neovim/0.11.0/bin/nvim --version
```

Extract the backup into a separate recovery directory first; avoid overwriting
newer configuration work. Old kegs and their dependencies remain available
only until Homebrew cleanup removes them. On Ubuntu, switching back requires
both the previous executable on PATH and the matching saved configuration.

### Validation

After setup, `:checkhealth nvim-treesitter`, `:LspInfo`, and `:VueToolsInfo`
help confirm tool availability. From the configuration directory, this smoke
check exercises the configured parsers and injections, native Telescope sorting,
and basic Oil/Gitsigns/Harpoon behavior (it creates a temporary Git repository):

```sh
nvim --headless -i NONE -n '+luafile tests/smoke.lua' '+qa!'
```

The 0.12.6 migration was tested on macOS: all 21 configured parsers and query
dependencies load, JSX/TSX and Vue/Markdown injections work, and the editor
smoke check passes. Live checks covered Lua, Python, C/C++, Go, TypeScript,
Vue 2.5/2.7/3.5, and Nuxt 2.15/4.6, plus hover styling and error-navigation
floats. Other vendored plugins were retained because these checks passed.
Ubuntu commands and platform-specific builds still need validation on Ubuntu.

## File explorer

Oil opens automatically for directory buffers (`nvim .`). Press `-` or
`<Space>e` to browse the current file's parent directory. Inside Oil, press
Enter to open an entry, `-` to go up, and `g?` for help. Hidden files are shown.
Edit filenames and save with `:w` to apply filesystem changes.

## Telescope search

Telescope uses the vendored telescope-fzf-native extension for native fuzzy
sorting of files and other results, with smart-case matching. This builds its
own C library and does not use the `fzf` executable.

On a new machine, install make and a C compiler, then run this from the
configuration directory:

```sh
make -C vendor/telescope-fzf-native.nvim
```

Lazy.nvim also has a `make` build hook for the extension. Generated binaries
are ignored by Git. If the library is unavailable, Telescope warns and uses
its built-in Lua sorter. Rebuild and restart Neovim to enable native sorting.
The pinned upstream revision is in the extension's `VENDORED.md`.

`<Space>sf` lists files using `rg --files`, falling back to fd or find when
needed. `<Space>f` lists Git-tracked files. `<Space>sg` searches file contents
and requires ripgrep. The native sorter does not change these search tools.

## Tree-sitter highlighting

The vendored nvim-treesitter plugin uses its Neovim 0.12 `main` implementation,
pinned in `vendor/nvim-treesitter/VENDORED.md`. Native highlighting is enabled;
indentation, folding, and incremental selection retain their existing behavior.

Run `:TSInstallConfigured` to install or update parsers for Lua, Python,
JavaScript/JSX, TypeScript, TSX, C, C++, Go (including go.mod, go.sum, and
go.work), Vue, HTML, CSS, SCSS, JSON, Markdown (including inline
markup and code injections), Vim script, Vim help, and Tree-sitter queries.
The command downloads source revisions pinned in the vendored
`lua/nvim-treesitter/parsers.lua` table and compiles them locally. It installs
missing languages and query dependencies, updates changed revisions, and
checks that configured parsers and highlight queries load. It requires network
access, a C compiler, curl, tar, and Tree-sitter CLI >=0.26.1 (tested: 0.27.1).
Parsers and installed queries live under `stdpath("data")/treesitter-0.12`,
outside this repository, and must be installed on each machine. Bundled
queries remain vendored; some query files come from pinned grammar sources.

Normal startup never installs or updates parsers. Installed parsers work
offline; files without a supported parser keep ordinary syntax highlighting.
After changing the vendored plugin revision, rerun `:TSInstallConfigured`
and restart Neovim to keep parser libraries and highlighting queries aligned.
Use `:TSLog` and `:checkhealth nvim-treesitter` to diagnose installation
problems; `:Inspect` shows highlighting under the cursor. The old
`:TSInstallInfo` and `nvim-treesitter.configs` API are no longer used.

## Language support

The vendored nvim-lspconfig supplies server configurations. Server executables
are separate system/project dependencies; only installed servers are enabled:

| Language | Executable on PATH |
| --- | --- |
| Lua | `lua-language-server` |
| C / C++ | `clangd` |
| Go | `gopls` (also needs the Go toolchain) |
| Python | `pyright-langserver` |
| JavaScript / TypeScript (including JSX / TSX) | `typescript-language-server` (also needs `typescript`) |

All listed servers are installed on the current machine. Plugin source stays in
`vendor/`; server runtimes stay outside this repository to avoid vendoring
platform-specific binaries and large dependency trees. Restart Neovim after
installing a server. Add further servers in `lua/config/lsp.lua`.

Go uses `gopls` for completion, navigation, diagnostics, code actions, and
formatting through the existing LSP shortcuts. Open files inside a Go module
(`go.mod`) or workspace (`go.work`) so gopls can discover the project. To
install gopls into a directory on PATH on this machine:

```sh
GOBIN="$HOME/.local/bin" go install golang.org/x/tools/gopls@latest
```

Run `:TSInstallConfigured` after setup to install the Go highlighting parsers.
`<Space>lf` formats the current Go buffer; formatting on save is not enabled.

### Vue and Nuxt

Vue single-file components use the official Vue language server together with
`ts_ls` and the matching Vue TypeScript plugin. Existing Blink completion and
LSP shortcuts apply in templates and scripts. Vue 2 applications use a legacy
profile; Vue 3 applications use a modern profile. Profiles are selected from
the installed Vue package, falling back to the installed Nuxt major version.
Separate application roots can use different profiles in the same session.
The nearest `package.json` defines the application root; dependencies can be
hoisted into a parent directory. npm and pnpm node_modules layouts are supported;
Yarn Plug'n'Play without node_modules is not configured.

Install Node.js 20 or newer, npm, and the Tree-sitter build prerequisites above.
Your Nuxt project may require a newer supported Node.js release; use its own
documented runtime requirements when preparing or running the application.
From this configuration directory, run:

```sh
sh tools/vue/install.sh
```

This explicitly installs both pinned profiles into
`stdpath("data")/vue-tools/{legacy,modern}`. It does not modify your work
repositories or your global npm installation. An optional first argument sets
the Neovim data directory, useful with custom XDG paths or NVIM_APPNAME.
The manifests and npm lockfiles in `tools/vue/` are committed; node_modules
stays outside the configuration. Installation uses `npm ci` with lifecycle
scripts disabled. Rerun the same command after tool lockfiles change.
Startup does not install or download anything.

The legacy profile pins Vue Language Tools 3.0.8, which retains Vue 2 support.
The modern profile pins 3.3.13; both use TypeScript 5.9.3 and
typescript-language-server 5.1.3.
An application's installed TypeScript 5.9 takes precedence; older build-time
TypeScript installations remain untouched and the editor uses the profile's
TypeScript instead. TypeScript 6/7 projects also use this editor fallback and
may need a future tool-profile update for newer compiler features.

Install the work project's dependencies with its usual package manager.
Restart Neovim and run `:TSInstallConfigured` for Vue and embedded highlighting.
Open a `.vue` file and run `:VueToolsInfo` to see the selected application root,
profile, dependency versions, and TypeScript path. `:LspInfo` should show
`vue_ls` and `ts_ls` attached; ordinary JS/TS files in the application use
the same profile's `ts_ls`.

**Vue 2 / Nuxt 2:** keep the application's existing tsconfig.json or
jsconfig.json. Ensure it includes `.vue` sources and describes aliases such
as `~/*` and `@/*` using the actual source directory. If automatic Vue target
detection needs an override, add this top-level field to that project config
(use `2.7` for Vue 2.7, `2` for Vue 2.5/2.6):

```json
{ "vueCompilerOptions": { "target": 2 } }
```

For TypeScript Nuxt 2 projects, retain existing `@nuxt/types` declarations
and installed module types. For JavaScript projects, jsconfig.json can enable
navigation without enabling `checkJs`. Nuxt 2 generated globals, Vuex stores,
injected plugins, and global components may need explicit declarations in the
application; installing an editor server cannot infer all of them.

**Modern Nuxt:** preserve the project's Nuxt-generated TypeScript setup
(older versions extend `.nuxt/tsconfig.json`; newer versions use generated
project references). After installing dependencies, run the project's local
Nuxt prepare command, for example:

```sh
./node_modules/.bin/nuxt prepare
```

Missing `.nuxt` declarations commonly cause unresolved composables, components,
or aliases. Regenerate them after changing Nuxt modules/configuration. Neovim
does not run project preparation commands automatically.

If detection is ambiguous, set a personal override in `init.lua` **before**
`require("config.lazy")`, using the absolute nearest package.json directory:

```lua
vim.g.vue_project_profiles = {
  ["/absolute/path/to/old-app"] = "legacy",
  ["/absolute/path/to/new-app"] = "modern",
}
```

Restart after installing dependencies or changing overrides; detection is cached
for the session. If no profile is selected, install application dependencies or
add an override. If tools are missing, rerun the installer. For missing aliases
or imports, check the application's tsconfig/jsconfig and generated declarations
before changing servers. Formatting remains manual
through `<Space>lf` when supported; ESLint integration and formatting on save
are not enabled by this setup.

Validated with Vue 2.5.22, 2.7.16, and 3.5.22 for completion, hover, definitions,
and diagnostics, plus Nuxt 2.15.8 aliases and Nuxt 4.6.2 generated types,
composables, and component navigation. This checks editor integration, rather
than application builds; individual projects can still need their own type
declarations and configuration.

C and C++ use the existing Apple clangd 17 installation. The usual LSP
navigation, diagnostics, formatting, and Blink completion shortcuts apply.
`:LspClangdSwitchSourceHeader` switches between source and header files.
For projects with custom include paths, defines, or compiler flags, provide
`compile_commands.json` in the project root (for CMake, configure with
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` and link or copy the generated file from
the build directory to the project root). Simple projects can use
`compile_flags.txt` instead. Without either, clangd uses fallback compile flags.
See the [clangd project setup guide](https://clangd.llvm.org/installation#project-setup).

Completion uses vendored blink.cmp v1.10.2 with automatic suggestions from
LSP, filesystem paths, and words in visible buffers. Buffer words appear
alongside LSP and path results, including when no server is attached.
`Ctrl-Space` opens suggestions (or toggles documentation when already open),
`Ctrl-J` / `Ctrl-K` select the next / previous candidate, `Ctrl-Y` accepts it, and `Ctrl-E`
dismisses the menu. Nothing is preselected or inserted until requested;
Enter inserts a newline. Tab / Shift-Tab move through active snippet
placeholders. Server-provided snippets use Neovim's built-in snippet engine;
no additional snippet collection is installed.

Blink uses its Lua matcher, so startup requires no binary download or Rust
build. This trades the Rust matcher's typo resistance and performance for
portability. Command-line and terminal completion are disabled.
See `vendor/blink.cmp/VENDORED.md` for the pinned upstream revision.

LSP buffers have these shortcuts (leader is Space):

| Key | Action |
| --- | --- |
| `gd` / `gD` | Definition / declaration |
| `gr` / `gi` | References / implementation |
| `K` | Hover documentation |
| `<Space>rn` | Rename symbol |
| `<Space>ca` | Code action |
| `<Space>ld` | Line diagnostics |
| `<Space>lj` | Next error and its message (wraps within the current buffer) |
| `<Space>lk` | Previous error and its message (wraps within the current buffer) |
| `<Space>lf` | Format using an attached server that supports formatting |
| `[d` / `]d` | Previous / next diagnostic (Neovim defaults) |

`<Space>lf` overrides the global ESLint command in LSP buffers. Pyright does
not provide formatting. Run `:LspInfo` to inspect enabled servers and clients.

Upstream documentation: [Oil](https://github.com/stevearc/oil.nvim),
[Neovim LSP](https://neovim.io/doc/user/lsp/).
