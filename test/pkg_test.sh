#!/usr/bin/env bash
# Tests for bin/pkg: manifest resolution across managers, unavailability
# handling, and dry-run install command composition. Uses a mock manifest
# via PKG_MANIFEST and forces the manager via PKG_MANAGER, so nothing is
# installed and no real package manager is required.

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/pkg"

setup() {
  manifest=$(mktemp)
  {
    printf '# a leading comment block\n'
    printf '# second comment line\n'
    printf 'logical\tapt\tpacman\tapk\n'
    printf 'foo\tfoo-apt\tfoo-pac\t-\n'
    printf 'bar\tbar-apt\tbar-pac\tbar-apk\n'
  } > "$manifest"
}

teardown() {
  command rm -f "$manifest"
}

run() { PKG_MANIFEST="$manifest" PKG_MANAGER="$1" "$PKG" "${@:2}"; }

test_resolve_apt_column() {
  assert_equals $'foo-apt\nbar-apt' "$(run apt resolve foo bar 2>/dev/null)"
}

test_resolve_pacman_column() {
  assert_equals "foo-pac" "$(run pacman resolve foo 2>/dev/null)"
}

test_resolve_preserves_request_order() {
  assert_equals $'bar-apt\nfoo-apt' "$(run apt resolve bar foo 2>/dev/null)"
}

test_unavailable_dash_is_skipped_not_printed() {
  # foo is "-" under apk: no stdout, warning on stderr.
  assert_equals "" "$(run apk resolve foo 2>/dev/null)"
}

test_unavailable_dash_warns_on_stderr() {
  assert_matches "unavailable via apk" "$(run apk resolve foo 2>&1 1>/dev/null)"
}

test_unknown_logical_warns() {
  assert_matches "no manifest entry for nope" "$(run apt resolve nope 2>&1 1>/dev/null)"
}

test_missing_manager_column_fails() {
  # dnf is not a column in the mock manifest.
  assert_status_code 3 "PKG_MANIFEST='$manifest' PKG_MANAGER=dnf '$PKG' resolve foo"
}

test_detect_honors_override() {
  assert_equals "apt" "$(run apt detect 2>/dev/null)"
}

test_logicals_lists_all_entries() {
  assert_equals $'foo\nbar' "$(PKG_MANIFEST="$manifest" "$PKG" logicals)"
}

test_dry_install_composes_apt_command() {
  assert_matches "apt-get install -y foo-apt bar-apt" \
    "$(run apt -n install foo bar 2>/dev/null)"
}

test_dry_install_composes_pacman_command() {
  assert_matches "pacman -S --needed --noconfirm foo-pac bar-pac" \
    "$(run pacman -n install foo bar 2>/dev/null)"
}
