#!/usr/bin/env bash
# REA-Schnittstellenanalyse für 7DTD_700 — läuft LOKAL gegen die eigene Spielinstallation.
# Rohdaten landen in .rea/ (gitignored). Ins Repo kommen nur kuratierte Findings (docs/rea/findings/).
#
# Nutzung:
#   export SDTD_PATH="/pfad/zu/7 Days To Die"
#   tools/rea/discover.sh baseline
#   tools/rea/discover.sh types <Feature-ID> <Typ.FullName> [<Typ.FullName> ...]
#   tools/rea/discover.sh inventory
#   tools/rea/discover.sh compare <alte Assembly-CSharp.dll> <neue Assembly-CSharp.dll>
#
# REA: https://github.com/morluto/rea  (npm: rea-agents). Flags vor Erstnutzung mit
#   rea <befehl> --help  gegenprüfen — REA ändert sich schnell.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="$REPO_ROOT/.rea"
STAMP="$(date +%Y%m%d-%H%M%S)"

if command -v rea >/dev/null 2>&1; then
  REA=(rea)
else
  REA=(npx -y rea-agents@latest)
fi

die() { echo "error: $*" >&2; exit 1; }

assembly_path() {
  [[ -n "${SDTD_PATH:-}" ]] || die "SDTD_PATH ist nicht gesetzt (Pfad zur 7DTD-Installation)."
  local dll="$SDTD_PATH/7DaysToDie_Data/Managed/Assembly-CSharp.dll"
  [[ -f "$dll" ]] || die "Assembly nicht gefunden: $dll"
  printf '%s' "$dll"
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

cmd_baseline() {
  local dll; dll="$(assembly_path)"
  local dir="$OUT_DIR/baseline-$STAMP"; mkdir -p "$dir"
  echo "Assembly: $dll"
  echo "SHA-256:  $(sha256_of "$dll")" | tee "$dir/sha256.txt"
  "${REA[@]}" inspect-managed-artifact "$dll" --json > "$dir/artifact.json"
  local harmony="$SDTD_PATH/7DaysToDie_Data/Managed/0Harmony.dll"
  if [[ -f "$harmony" ]]; then
    "${REA[@]}" inspect-managed-artifact "$harmony" --json > "$dir/harmony-artifact.json"
  else
    echo "Hinweis: keine 0Harmony.dll im Managed-Ordner gefunden." | tee "$dir/harmony-note.txt"
  fi
  echo "Fertig → $dir"
  echo "Jetzt docs/rea/findings/00-build-baseline.md ausfüllen (Version, SHA-256, MVID, Runtime, Framework)."
}

cmd_types() {
  local feature="${1:-}"; shift || true
  [[ -n "$feature" && $# -gt 0 ]] || die "Nutzung: types <Feature-ID> <Typ> [<Typ> ...]"
  local dll; dll="$(assembly_path)"
  local dir="$OUT_DIR/$feature-$STAMP"; mkdir -p "$dir"
  local args=()
  for t in "$@"; do args+=(--type "$t"); done
  "${REA[@]}" inspect-managed-members "$dll" "${args[@]}" \
    --detail summary --evidence-bundle "$dir/members.bundle.json" --json > "$dir/summary.json"
  echo "Summary → $dir/summary.json (unmatched-Typen dort prüfen)"
  echo "Vollständige Evidence → $dir/members.bundle.json (Seiten via 'rea inspect-analysis-view')"
}

cmd_inventory() {
  local dll; dll="$(assembly_path)"
  local dir="$OUT_DIR/inventory-$STAMP"; mkdir -p "$dir"
  "${REA[@]}" inspect-managed-members "$dll" \
    --detail summary --evidence-bundle "$dir/members.bundle.json" --json > "$dir/summary.json"
  echo "Typ-Inventar (Summary) → $dir/summary.json"
}

cmd_compare() {
  local old="${1:-}" new="${2:-}"
  [[ -f "$old" && -f "$new" ]] || die "Nutzung: compare <alte.dll> <neue.dll>"
  local manifest="$REPO_ROOT/docs/rea/findings/patch-manifest.md"
  # Spalte 2 (Typ) aus der Manifest-Tabelle, Kopf/Trenner/Platzhalter überspringen
  mapfile -t types < <(awk -F'|' '/^\|/ { gsub(/^[ \t`]+|[ \t`]+$/, "", $3); if ($3 != "" && $3 != "–" && $3 != "Typ" && $3 !~ /^-+$/) print $3 }' "$manifest" | sort -u)
  [[ ${#types[@]} -gt 0 ]] || die "Patch-Manifest enthält noch keine Typen."
  local dir="$OUT_DIR/compare-$STAMP"; mkdir -p "$dir"
  local args=()
  for t in "${types[@]}"; do args+=(--type "$t"); done
  "${REA[@]}" compare-managed-members "$old" "$new" "${args[@]}" --json > "$dir/compare.json"
  echo "Vergleich für ${#types[@]} gepatchte Typen → $dir/compare.json"
  echo "Jede geänderte Signatur eines gepatchten Members blockiert das Release."
}

case "${1:-}" in
  baseline)  shift; cmd_baseline "$@" ;;
  types)     shift; cmd_types "$@" ;;
  inventory) shift; cmd_inventory "$@" ;;
  compare)   shift; cmd_compare "$@" ;;
  *) sed -n '2,13p' "$0"; exit 1 ;;
esac
