#!/usr/bin/env bash
# Installs the python.org CPython builds this setup expects, then points uv at them.
#
# Run after install.sh on a new Mac. Safe to re-run; installed versions are skipped
# unless --force is passed.
#
#   ./setup_python.sh            install missing versions
#   ./setup_python.sh --force    reinstall everything
#   ./setup_python.sh --dry-run  print what would happen
#
# Rebuilding project virtualenvs is deliberately out of scope. Each repo's own
# `just install` does that, and direnv recreates .venv on the next cd.
set -euo pipefail

# Newest macOS installer per line. 3.11 and 3.12 are security-only upstream, so
# their last binary release is older than the current source release.
VERSIONS=(
  "3.11:3.11.9"
  "3.12:3.12.10"
  "3.13:3.13.15"
  "3.14:3.14.7"
  "3.15:3.15.0rc1"
)

# Lines that also get the optional free-threaded build as python3.Xt.
FREETHREADED=(3.14 3.15)

# Backs bare `python3` and `pip3`. The PATH entry that selects it lives in bashrc.
DEFAULT_VERSION=3.11

PSF_TEAM_ID="BMM5U3QVKW"
FORCE=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --force)   FORCE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

[ "$(uname -s)" = "Darwin" ] || { echo "error: macOS only" >&2; exit 1; }

run() { if [ "$DRY_RUN" = 1 ]; then echo "  would run: $*"; else "$@"; fi; }

is_freethreaded() {
  local v="$1" f
  for f in "${FREETHREADED[@]}"; do [ "$f" = "$v" ] && return 0; done
  return 1
}

WORKDIR=$(mktemp -d -t setup-python)
trap 'rm -rf "$WORKDIR"' EXIT

echo "==> Installing python.org CPython"
INSTALLED_ANY=0
for entry in "${VERSIONS[@]}"; do
  series="${entry%%:*}"; full="${entry##*:}"

  if [ "$FORCE" = 0 ] && [ -x "/Library/Frameworks/Python.framework/Versions/$series/bin/python3" ]; then
    have=$("/Library/Frameworks/Python.framework/Versions/$series/bin/python3" -c 'import platform; print(platform.python_version())' 2>/dev/null || echo "?")
    if [ "$have" = "$full" ]; then
      echo "  $series: $full already installed"
      continue
    fi
    echo "  $series: found $have, want $full"
  fi

  # Release-candidate installers live under the final version's directory.
  dir=$(echo "$full" | sed -E 's/(a|b|rc)[0-9]+$//')
  pkg="python-$full-macos11.pkg"
  url="https://www.python.org/ftp/python/$dir/$pkg"

  echo "  $series: downloading $full"
  run curl -fsSL -o "$WORKDIR/$pkg" "$url"

  if [ "$DRY_RUN" = 0 ]; then
    pkgutil --check-signature "$WORKDIR/$pkg" | grep -q "Python Software Foundation ($PSF_TEAM_ID)" \
      || { echo "error: $pkg is not signed by the PSF" >&2; exit 1; }
  fi

  # Skip IDLE and the docs. Skip the shell profile updater too: every installer
  # prepends its own framework bin to ~/.zprofile, so whichever ran last would
  # silently own bare `python3`. Versioned /usr/local/bin links do the job instead.
  ft=0; is_freethreaded "$series" && ft=1
  {
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
    echo '<plist version="1.0"><array>'
    for c in "PythonFramework:1" "PythonUnixTools:1" "PythonInstallPip:1" \
             "PythonApplications:0" "PythonDocumentation:0" "PythonProfileChanges:0" \
             "PythonTFramework:$ft"; do
      printf '<dict><key>choiceIdentifier</key><string>org.python.Python.%s-%s</string><key>choiceAttribute</key><string>selected</string><key>attributeSetting</key><integer>%s</integer></dict>\n' \
        "${c%%:*}" "$series" "${c##*:}"
    done
    echo '</array></plist>'
  } > "$WORKDIR/choices-$series.xml"

  echo "  $series: installing (needs sudo)"
  run sudo installer -pkg "$WORKDIR/$pkg" -applyChoiceChangesXML "$WORKDIR/choices-$series.xml" -target /
  INSTALLED_ANY=1

  certs="/Applications/Python $series/Install Certificates.command"
  [ -f "$certs" ] && run bash "$certs" >/dev/null 2>&1 || true
done

# The UNIX tools component links python3.Xt whether or not the free-threaded
# framework was installed, leaving broken symlinks on the lines that skip it.
echo "==> Cleaning broken symlinks"
for f in /usr/local/bin/python3*; do
  if [ -L "$f" ] && [ ! -e "$f" ]; then
    echo "  removing $f"
    run sudo rm -f "$f"
  fi
done

echo "==> Pointing /usr/local/bin/python3 at $DEFAULT_VERSION"
for name in python3 python3-config; do
  target="../../../Library/Frameworks/Python.framework/Versions/$DEFAULT_VERSION/bin/$name"
  [ -e "/Library/Frameworks/Python.framework/Versions/$DEFAULT_VERSION/bin/$name" ] \
    && run sudo ln -sfn "$target" "/usr/local/bin/$name"
done

echo "==> Configuring uv"
if command -v uv >/dev/null 2>&1; then
  if [ "$DRY_RUN" = 0 ]; then
    mkdir -p ~/.config/uv
    cat > ~/.config/uv/uv.toml <<'UVTOML'
# Use only interpreters already installed on this machine, and never download a
# managed one. Without this, `uv run` and `uv venv` silently pull their own
# CPython and projects end up pinned to interpreters nothing else can see.
python-preference = "only-system"
python-downloads = "never"
UVTOML
    echo "  wrote ~/.config/uv/uv.toml"
  else
    echo "  would write ~/.config/uv/uv.toml"
  fi

  # Match on the full cpython- key. A bare `uv python uninstall 3.13` also
  # matches pyodide-3.13.x and removes it.
  managed=$(ls -1 "$(uv python dir 2>/dev/null)" 2>/dev/null | grep '^cpython-' || true)
  if [ -n "$managed" ]; then
    echo "  removing uv-managed CPython:"
    echo "$managed" | sed 's/^/    /'
    while read -r key; do
      [ -n "$key" ] && run uv python uninstall "$key"
    done <<< "$managed"
  else
    echo "  no uv-managed CPython to remove"
  fi

  # Tools built against a removed interpreter keep a dangling venv.
  for tool in $(ls -1 "$(uv tool dir 2>/dev/null)" 2>/dev/null || true); do
    cfg="$(uv tool dir)/$tool/pyvenv.cfg"
    [ -f "$cfg" ] || continue
    home=$(awk -F' = ' '/^home/{print $2}' "$cfg")
    if [ ! -x "$home/python3" ] && [ ! -x "$home/python" ]; then
      echo "  rebuilding tool: $tool"
      run uv tool install --reinstall "$tool"
    fi
  done
else
  echo "  uv not installed, skipping"
fi

echo
echo "==> Installed"
for entry in "${VERSIONS[@]}"; do
  series="${entry%%:*}"
  bin="/usr/local/bin/python3.$(echo "$series" | cut -d. -f2)"
  [ -x "$bin" ] && printf '  %-28s %s\n' "$bin" "$("$bin" -V 2>&1)"
  t="${bin}t"
  [ -x "$t" ] && printf '  %-28s %s (GIL: %s)\n' "$t" "$("$t" -V 2>&1)" "$("$t" -c 'import sys; print(sys._is_gil_enabled())' 2>&1)"
done

# bashrc puts the default framework's bin ahead of Homebrew, and only an
# interactive shell sources it, so resolve the way a login shell would.
resolved=$(zsh -ic 'command -v python3' 2>/dev/null || command -v python3)
echo
printf '  python3 resolves to %s (%s)\n' "$resolved" "$("$resolved" -V 2>&1)"
case "$resolved" in
  "/Library/Frameworks/Python.framework/Versions/$DEFAULT_VERSION/"*) ;;
  *) echo "  warning: expected the $DEFAULT_VERSION framework. Check that bashrc prepends"
     echo "           /Library/Frameworks/Python.framework/Versions/$DEFAULT_VERSION/bin to PATH." ;;
esac

if [ "$INSTALLED_ANY" = 1 ]; then
  echo "  Open a new shell to pick up PATH changes."
fi
