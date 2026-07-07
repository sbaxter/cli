#!/usr/bin/env bash
# Backend-routing tests for bin/clip.
#
# We can't exercise a real Linux clipboard on macOS, so each backend is
# shimmed with a pure-bash recorder (absolute shebang, builtins only, so it
# runs under a PATH containing nothing but the shims). clip is then run with
# that restricted PATH and controlled DISPLAY/WAYLAND_DISPLAY, and we assert
# it dispatched to the expected backend with the expected args and bytes.
# shellcheck disable=SC2317

CLIP="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/clip"
BASH_BIN="$(command -v bash)"

setup() {
  shimdir=$(mktemp -d)
  rec="$shimdir/.called"
  out="$shimdir/.data"
  : > "$rec"
}

teardown() {
  command rm -rf "$shimdir"
}

# make_shim <name>: an executable recorder that logs "<name>|<args>" to
# $SHIM_REC and writes its stdin to $SHIM_OUT, using only bash builtins.
make_shim() {
  local name="$1"
  # The $-expressions below are literal on purpose: they belong to the
  # generated shim and expand when it runs, not while we author it.
  {
    printf '#!/bin/bash\n'
    # shellcheck disable=SC2016
    printf 'printf "%%s\\n" "%s|$*" >> "$SHIM_REC"\n' "$name"
    # shellcheck disable=SC2016
    printf 'IFS= read -r -d "" _a || true; printf "%%s" "$_a" > "$SHIM_OUT"\n'
  } > "$shimdir/$name"
  chmod +x "$shimdir/$name"
}

# run_clip <NAME=VAL ...>: invoke clip with PATH restricted to the shims.
run_clip() {
  env -i PATH="$shimdir" SHIM_REC="$rec" SHIM_OUT="$out" "$@" \
    "$BASH_BIN" "$CLIP"
}

test_pbcopy_wins_even_with_display_set() {
  make_shim pbcopy; make_shim wl-copy; make_shim xclip
  printf data | run_clip WAYLAND_DISPLAY=wayland-0 DISPLAY=:0
  assert_equals "pbcopy|" "$(cat "$rec")"
}

test_wayland_chosen_when_no_pbcopy() {
  make_shim wl-copy; make_shim xclip; make_shim xsel
  printf data | run_clip WAYLAND_DISPLAY=wayland-0 DISPLAY=:0
  assert_equals "wl-copy|" "$(cat "$rec")"
}

test_x11_chosen_when_no_wayland_display() {
  make_shim wl-copy; make_shim xclip; make_shim xsel
  # wl-copy is installed but WAYLAND_DISPLAY is unset — must skip to xclip.
  printf data | run_clip DISPLAY=:0
  assert_equals "xclip|-selection clipboard" "$(cat "$rec")"
}

test_xsel_is_last_resort() {
  make_shim xsel
  printf data | run_clip DISPLAY=:0
  assert_equals "xsel|--clipboard --input" "$(cat "$rec")"
}

test_bytes_reach_backend_unchanged() {
  make_shim xclip
  printf 'multi\nline payload' | run_clip DISPLAY=:0
  assert_equals $'multi\nline payload' "$(cat "$out")"
}

test_no_backend_fails_loudly() {
  # empty shimdir: no backend at all
  assert_fails "printf '' | run_clip"
}
