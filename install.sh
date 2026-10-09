#!/usr/bin/env sh
# Install the FFF skill into every agent home present on this machine.
#
#   ./install.sh              # every home that exists
#   ./install.sh claude codex # only these
#
# Targets:
#   dsh     $DSH_HOME            or ~/.dsh      (DeepSeek Harness)
#   claude  $CLAUDE_CONFIG_DIR   or ~/.claude   (Claude Code)
#   codex   $CODEX_HOME          or ~/.codex    (Codex)
set -eu

# Where to fetch SKILL.md from when this script runs without the repo next to it,
# for example:  curl -fsSL https://raw.githubusercontent.com/zeelinkCN/FFF-skill/main/install.sh | sh
src_url="${FFF_SKILL_URL:-https://raw.githubusercontent.com/zeelinkCN/FFF-skill/main/SKILL.md}"

src="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)/SKILL.md"
if [ ! -f "$src" ]; then
    echo "SKILL.md not found locally - downloading $src_url" >&2
    src="$(mktemp 2>/dev/null || echo /tmp/fff-skill.SKILL.md)"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$src_url" -o "$src"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$src" "$src_url"
    else
        echo "need curl or wget to download SKILL.md" >&2
        exit 1
    fi
fi

src_hash() { cksum <"$1" | awk '{print $1"-"$2}'; }

install_into() {
    name=$1
    home=$2
    if [ ! -d "$home" ]; then
        printf 'skip  %-6s (%s not found)\n' "$name" "$home"
        return 0
    fi
    dest="$home/skills/fff"
    mkdir -p "$dest"
    if [ -f "$dest/SKILL.md" ] && [ "$(src_hash "$src")" = "$(src_hash "$dest/SKILL.md")" ]; then
        printf 'ok    %-6s %s (already current)\n' "$name" "$dest/SKILL.md"
    else
        cp "$src" "$dest/SKILL.md"
        printf 'done  %-6s %s\n' "$name" "$dest/SKILL.md"
    fi
}

if [ "$#" -gt 0 ]; then
    for target in "$@"; do
        case $target in
            dsh)    install_into dsh    "${DSH_HOME:-$HOME/.dsh}" ;;
            claude) install_into claude "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ;;
            codex)  install_into codex  "${CODEX_HOME:-$HOME/.codex}" ;;
            *)      echo "unknown target: $target (use one of: dsh claude codex)" >&2; exit 2 ;;
        esac
    done
else
    install_into dsh    "${DSH_HOME:-$HOME/.dsh}"
    install_into claude "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    install_into codex  "${CODEX_HOME:-$HOME/.codex}"
fi
