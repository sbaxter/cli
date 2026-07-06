#!/usr/bin/env bash
# Portability tests for the in-place text-munging helpers in ../bashrc.
#
# These functions all edit a file in place with sed. `sed -i` is not
# portable: GNU wants `sed -i 's/x/y/' f`, BSD/macOS wants `sed -i '' ...`.
# The helpers must behave identically on both userlands.
#
# run: bash_unit test/sed_portability_test.sh
# shellcheck disable=SC1090,SC1091

# The functions live in bashrc, which early-returns unless PS1 is set.
# bash_unit sources this file under `set -e`; an interactive rc has plenty
# of harmless non-zero returns (tput, `test -f`), so disable errexit across
# the source or the test_* definitions below never get reached.
set +e
PS1=x
source "$(dirname "${BASH_SOURCE[0]}")/../bashrc" >/dev/null 2>&1
# bashrc defines interactive aliases (rm -i, mv -i); drop them so the
# assertions and teardown below aren't prompted at.
unalias -a 2>/dev/null || true

setup() {
  tmp=$(mktemp)
}

teardown() {
  command rm -f "$tmp"
}

test_upcase_lowercases_to_upper() {
  printf 'abc\nDeF\n' > "$tmp"
  upcase "$tmp"
  assert_equals $'ABC\nDEF' "$(cat "$tmp")"
}

test_downcase_uppers_to_lower() {
  printf 'ABC\ndEf\n' > "$tmp"
  downcase "$tmp"
  assert_equals $'abc\ndef' "$(cat "$tmp")"
}

test_dedup_removes_consecutive_duplicates() {
  printf 'one\none\ntwo\n' > "$tmp"
  dedup "$tmp"
  assert_equals $'one\ntwo' "$(cat "$tmp")"
}

test_unDOS_strips_trailing_cr() {
  printf 'abc\r\ndef\r\n' > "$tmp"
  unDOS "$tmp"
  assert_equals $'abc\ndef' "$(cat "$tmp")"
}

test_noextraspaces_trims_both_ends() {
  printf '  abc  \n\tdef\t\n' > "$tmp"
  noextraspaces "$tmp"
  assert_equals $'abc\ndef' "$(cat "$tmp")"
}

test_trailingspaces_trims_right() {
  printf 'abc   \ndef\t\n' > "$tmp"
  trailingspaces "$tmp"
  assert_equals $'abc\ndef' "$(cat "$tmp")"
}

test_trails_trims_right() {
  printf 'abc   \ndef\t\n' > "$tmp"
  trails "$tmp"
  assert_equals $'abc\ndef' "$(cat "$tmp")"
}
