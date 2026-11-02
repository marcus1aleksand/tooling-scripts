#!/usr/bin/env bash
# shellcheck disable=SC2034  # the state arrays are consumed by the sourced tooling_setup.sh
# Regression tests for the interactive selection mapping in tooling_setup.sh.
#
# Run with: bash tests/test_selection_mapping.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../tooling_setup.sh
source "$REPO_ROOT/tooling_setup.sh"

FAILURES=0

pass() { printf '  ok   - %s\n' "$1"; }

fail_case() {
  printf '  FAIL - %s\n' "$1"
  FAILURES=$((FAILURES + 1))
}

assert_eq() {
  local expected="$1" actual="$2" message="$3"
  if [[ "$expected" == "$actual" ]]; then
    pass "$message"
  else
    fail_case "$message (expected '$expected', got '$actual')"
  fi
}

echo "tooling-scripts selection mapping"

# --- Display names must be unique ---------------------------------------------
duplicate_displays=""
for entry in "${TOOLS[@]}"; do
  IFS='|' read -r _type _brew_name _display _cmd <<<"$entry"
  same=0
  for other in "${TOOLS[@]}"; do
    IFS='|' read -r _t _bn _other_display _c <<<"$other"
    if [[ "$_other_display" == "$_display" ]]; then
      same=$((same + 1))
    fi
  done
  if [[ $same -gt 1 ]]; then
    duplicate_displays="$_display"
  fi
done
if [[ -z "$duplicate_displays" ]]; then
  pass "every tool has a unique display name"
else
  fail_case "duplicate display name: $duplicate_displays"
fi

# --- A display name that prefixes another must not select both ----------------
GO_IDX="$(tool_index go)"
CHROME_IDX="$(tool_index google-chrome)"
GCP_IDX="$(tool_index google-cloud-sdk)"

IS_INSTALLED[$GO_IDX]=1
INSTALLED_VERSION[$GO_IDX]="1.22.0"
IS_INSTALLED[$CHROME_IDX]=1
INSTALLED_VERSION[$CHROME_IDX]="120.0"
IS_INSTALLED[$GCP_IDX]=1
INSTALLED_VERSION[$GCP_IDX]="480.0"

build_choices

SELECTED_LABELS=("$(label_for "$CHROME_IDX")")
resolve_selections
assert_eq "1" "${SELECTED_MAP[$CHROME_IDX]}" "selecting Google Chrome selects google-chrome"
assert_eq "0" "${SELECTED_MAP[$GO_IDX]}" "selecting Google Chrome does not select Go"
assert_eq "0" "${SELECTED_MAP[$GCP_IDX]}" "selecting Google Chrome does not select Google Cloud SDK"

SELECTED_LABELS=("$(label_for "$GO_IDX")")
resolve_selections
assert_eq "1" "${SELECTED_MAP[$GO_IDX]}" "selecting Go selects go"
assert_eq "0" "${SELECTED_MAP[$CHROME_IDX]}" "selecting Go does not select Google Chrome"

SELECTED_LABELS=("$(label_for "$GCP_IDX")")
resolve_selections
assert_eq "1" "${SELECTED_MAP[$GCP_IDX]}" "selecting Google Cloud SDK selects google-cloud-sdk"
assert_eq "0" "${SELECTED_MAP[$GO_IDX]}" "selecting Google Cloud SDK does not select Go"

# --- An unknown selection must not select anything ----------------------------
SELECTED_LABELS=("Not A Tool  (not installed)")
resolve_selections
assert_eq "0" "${SELECTED_MAP[$GO_IDX]}" "an unknown selection selects nothing"

# --- An empty selection must not select anything ------------------------------
SELECTED_LABELS=()
resolve_selections
assert_eq "0" "${SELECTED_MAP[$GO_IDX]}" "an empty selection selects nothing"

# --- The script must stay loadable by bash 3.2 (macOS default) ----------------
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  pass "running on bash ${BASH_VERSION} (associative arrays avoided)"
else
  pass "running on bash ${BASH_VERSION}"
fi

if [[ $FAILURES -gt 0 ]]; then
  printf '\n%d check(s) failed\n' "$FAILURES"
  exit 1
fi

printf '\nAll checks passed\n'
