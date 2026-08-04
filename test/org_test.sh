#!/usr/bin/env bash
# Tests for the org/gclone forge machinery in bashrc.
#
# bashrc defines org() and gclone() but bails immediately when PS1 is unset
# (the non-interactive guard), and bash strips PS1 from non-interactive
# shells -- so each case sets PS1 and sources bashrc inside a command
# substitution, giving a hermetic subshell we can probe without leaking env
# between tests. _org_data / ORG_LIST come from the private repo at runtime,
# so we stub them here. git is stubbed in the gclone cases so nothing clones.
#
# SC1090: bashrc path is dynamic. SC2034: ORG_LIST/REPO are read by the
# sourced bashrc functions, not directly by this file. SC2317: the git stub
# is reached indirectly through gclone.
# shellcheck disable=SC1090,SC2034,SC2317

BASHRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bashrc"

# A throwaway HOME keeps bashrc's trailing `source ~/.bash_profile` from
# pulling in the caller's real private profile (whose own `org` call would
# clobber the env we set up per case).
run_org() {
  HOME=$(mktemp -d) PS1=x
  source "$BASHRC" >/dev/null 2>&1
  eval "_org_data() { echo '$1'; }"
  ORG_LIST=shb
  org shb >/dev/null 2>&1
}

# gclone: source bashrc with git stubbed to echo its argv, run gclone.
run_gclone() {
  HOME=$(mktemp -d) PS1=x
  source "$BASHRC" >/dev/null 2>&1
  git() { echo "git $*"; command mkdir -p "${@: -1}" 2>/dev/null; }
  REPO=$(mktemp -d)
  gclone "$@" 2>/dev/null
}

test_org_reads_forge_host_from_data() {
  assert_equals "gitlab.internal" \
    "$(run_org "B_CYAN:sbaxter::gitlab.internal"; echo "$FORGE_HOST")"
}

test_org_defaults_forge_host_to_github() {
  assert_equals "github.com" \
    "$(run_org "B_CYAN:sbaxter:"; echo "$FORGE_HOST")"
}

test_org_exports_forge_org() {
  assert_equals "sbaxter" \
    "$(run_org "B_CYAN:sbaxter::gitlab.internal"; echo "$FORGE_ORG")"
}

test_org_keeps_gh_org_alias() {
  assert_equals "sbaxter" \
    "$(run_org "B_CYAN:sbaxter:"; echo "$GH_ORG")"
}

test_gclone_uses_forge_host() {
  assert_matches "git@gitlab.internal:sbaxter/myrepo" \
    "$(FORGE_HOST=gitlab.internal FORGE_ORG=sbaxter SYSTEM='' run_gclone myrepo)"
}

test_gclone_defaults_to_github() {
  assert_matches "git@github.com:sbaxter/myrepo" \
    "$(FORGE_HOST=github.com FORGE_ORG=sbaxter SYSTEM='' run_gclone myrepo)"
}
