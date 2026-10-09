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
# for example:  curl -fsSL https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@main/install.sh | sh
# Official raw first, then the jsDelivr mirror (raw is often unreachable from CN networks).
if [ -n "${FFF_SKILL_URL:-}" ]; then
    src_urls="$FFF_SKILL_URL"
else
    src_urls="https://raw.githubusercontent.com/zeelinkCN/FFF-skill/main/SKILL.md
https://cdn.jsdelivr.net/gh/zeelinkCN/FFF-skill@main/SKILL.md"
fi

src="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)/SKILL.md"
if [ ! -f "$src" ]; then
    tmp="$(mktemp 2>/dev/null || echo /tmp/fff-skill.SKILL.md)"
    ok=""
    for url in $src_urls; do
        echo "SKILL.md not found locally - downloading $url" >&2
        if command -v curl >/dev/null 2>&1; then
            if curl -fsSL --connect-timeout 15 --max-time 120 "$url" -o "$tmp"; then ok=1; break; fi
        elif command -v wget >/dev/null 2>&1; then
            if wget -qO "$tmp" "$url"; then ok=1; break; fi
        else
            echo "need curl or wget to download SKILL.md" >&2
            exit 1
        fi
    done
    if [ -z "$ok" ]; then
        echo "could not download SKILL.md from any mirror" >&2
        exit 1
    fi
    src="$tmp"
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
