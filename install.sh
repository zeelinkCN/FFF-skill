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

src="$(cd "$(dirname "$0")" && pwd)/SKILL.md"
if [ ! -f "$src" ]; then
    echo "SKILL.md not found next to this script: $src" >&2
    exit 1
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
