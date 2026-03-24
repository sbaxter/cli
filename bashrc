#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# If not running interactively, don't do anything
test -z "$PS1" && return

# Source global definitions
test -f /etc/bashrc && source /etc/bashrc


# COLORS
# -----------------------------------------------------------------------------
    NO_COLOR=$(tput sgr0)
        BOLD=$(tput bold)
       BLACK=$(tput setaf 0)
         RED=$(tput setaf 1)
       GREEN=$(tput setaf 2)
      YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
     MAGENTA=$(tput setaf 5)
        CYAN=$(tput setaf 6)
       WHITE=$(tput setaf 7)
       B_RED=$BOLD$RED
      B_BLUE=$BOLD$BLUE
   B_MAGENTA=$BOLD$MAGENTA
      B_CYAN=$BOLD$CYAN
     B_WHITE=$BOLD$WHITE
     B_GREEN=$BOLD$GREEN
    B_YELLOW=$BOLD$YELLOW
     B_BLACK=$BOLD$BLACK
    ON_BLACK=$(tput setab 0)
      ON_RED=$(tput setab 1)
    ON_GREEN=$(tput setab 2)
   ON_YELLOW=$(tput setab 3)
     ON_BLUE=$(tput setab 4)
  ON_MAGENTA=$(tput setab 5)
     ON_CYAN=$(tput setab 6)
    ON_WHITE=$(tput setab 7)

export NO_COLOR BOLD BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
export B_RED B_BLUE B_MAGENTA B_CYAN B_WHITE B_GREEN B_YELLOW B_BLACK
export ON_BLACK ON_RED ON_GREEN ON_YELLOW ON_BLUE ON_MAGENTA ON_CYAN ON_WHITE

export LS_COLORS='di=0;32'
# -----------------------------------------------------------------------------


# DEFAULTS
# -----------------------------------------------------------------------------
: "${PROMPT_COLOR:=$YELLOW}"
: "${ORG:=}"
: "${SYSTEM:=}"
: "${REPO:=$HOME/git}"
: "${USER_TAG:="($USER)"}"
# -----------------------------------------------------------------------------


# TERMINAL
# -----------------------------------------------------------------------------
set -o vi

export VISUAL=vim
export EDITOR=$VISUAL
export GIT_EDITOR=$VISUAL

# Add bin files to $PATH
_bashrc="${BASH_SOURCE[0]}"
if test -h "$_bashrc"; then
  _cli_root=$(dirname "$(readlink "$_bashrc")")
  export PATH=$PATH:$_cli_root/bin
  export VI_CONFIG="$_cli_root/vi"
fi

export PATH=$PATH:/usr/local/bin:/usr/local/sbin

# cmd history
export HISTCONTROL=erasedups:ignoreboth
export HISTFILESIZE=500000
export HISTSIZE=100000
export HISTIGNORE="&:[ ]*:exit"
shopt -s histappend
shopt -s cmdhist

function reload {
  source "$HOME/.bashrc"
}

function title {
  echo -ne "\033]2;$1\007"
}
# -----------------------------------------------------------------------------


# PROMPT
# -----------------------------------------------------------------------------
function _gbranch {
  local sym
  sym=$(git symbolic-ref HEAD 2>/dev/null)
  test -z "$sym" && sym=$(git describe --contains --all HEAD 2>/dev/null)
  test -z "$sym" && sym=$(git rev-parse --short HEAD 2>/dev/null)
  echo "${sym##refs/heads/}"
}

function _gprompt {
  local branch w i u
  git status >/dev/null 2>&1 || return;

  if git log >/dev/null 2>&1; then
    branch=$(_gbranch)
    i=$(git diff-index --cached --quiet HEAD -- 2>/dev/null || echo "+")
  else
    branch='(init)'
    i=$(git diff --cached --quiet --exit-code || echo "+")
  fi

  w=$(git diff --no-ext-diff --quiet --exit-code || echo "!")
  u="$(test -z "$(git ls-files --others --exclude-standard -- ':/*' \
        2>/dev/null)" || echo "?")"

  echo "[$branch\[$CYAN\]$w$i$u\[$PROMPT_COLOR\]]"
}

function _prompt {
  local depth b e
  depth=$(pwd | sed 's/[^/]//g' | sed 's/^\///')
  b="$NO_COLOR$PROMPT_COLOR\n"
  e="$ON_BLACK$NO_COLOR"
  PS1="\[${b}\]$(_gprompt)\[$PROMPT_COLOR\][$HOSTNAME$USER_TAG:$depth\W]:\[$e\] "
  PS2="   \[$PROMPT_COLOR\]->\[$NO_COLOR\] "
}
PROMPT_COMMAND="_prompt"
# -----------------------------------------------------------------------------


# ALIASES
# -----------------------------------------------------------------------------
function _alias {
  alias "$1" >/dev/null 2>&1
  return
}

_alias ..     || alias ..='cd ..'
_alias ..2    || alias ..2='cd ../..'
_alias ..3    || alias ..3='cd ../../..'
_alias ..4    || alias ..4='cd ../../../..'
_alias ..5    || alias ..5='cd ../../../../..'
_alias back   || alias back='cd -'
_alias cp     || alias cp='cp -i'
_alias grep   || alias grep='grep --color=auto'
_alias ngrep  || alias ngrep='grep --color=auto --exclude-dir node_modules'
_alias ll     || alias ll='ls -hl'
_alias lla    || alias lla='ls -ahl'
_alias lsd    || alias lsd='ls -dl -- */'
_alias mv     || alias mv='mv -i'
_alias rm     || alias rm='rm -i'
_alias vi     || alias vi=vim
_alias blint  || alias blint='shellcheck -s bash'
_alias c      || alias c='copilot --model claude-opus-4.6 --allow-all-tools --add-dir .'
# -----------------------------------------------------------------------------


# GIT
# -----------------------------------------------------------------------------

# system-provided git completions
if test "$(uname -s)" = Darwin; then
  _git_comp="$(brew --prefix 2>/dev/null)/etc/bash_completion.d/git-completion.bash"
  test -f "$_git_comp" && source "$_git_comp"
else
  for _git_comp in \
    /usr/share/bash-completion/completions/git \
    /etc/bash_completion.d/git; do
    test -f "$_git_comp" && source "$_git_comp" && break
  done
fi

_hist="git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
# shellcheck disable=SC2139
_alias hist  || alias hist="$_hist"
_alias ga    || alias ga='git add'
_alias gc    || alias gc='git commit'
_alias gca   || alias gca='git commit --amend'
_alias gco   || alias gco='git checkout'
_alias gd    || alias gd='git diff'
_alias gdr   || alias gdr='git diff --cached -M --'
_alias gds   || alias gds='git diff --staged'
_alias gpick || alias gpick='git cherry-pick -x'
_alias gpr   || alias gpr='git merge --no-ff'
_alias gpt   || alias gpt='git push --tags'
_alias gpv   || alias gpv='git push --no-verify'
_alias gr    || alias gr='git pull --rebase'
_alias grm   || alias grm='git rm'
_alias groot || alias groot='cd $(git rev-parse --show-cdup) '
_alias gst   || alias gst='git status'
_alias gt    || alias gt='git tag -sam'

function grb {
  git for-each-ref --sort=-committerdate refs/remotes/ \
                   --format='%(refname:short)' \
                   --count=20
}

function gp {
  local branch remote
  git status >/dev/null 2>&1 || return;

  remote=origin
  test -z "$1" || remote="$1"

  branch=$(git symbolic-ref HEAD 2>/dev/null)
  test -z "$branch" && echo "Detached state?" && return 1
  echo "pushing to $remote/$branch"
  git push "$remote" "$branch"
}

function gu {
  local branch
  git status >/dev/null 2>&1 || return;

  branch=$(git symbolic-ref HEAD 2>/dev/null)
  test -z "$branch" && echo "Detached state?" && return 1
  echo "pulling from origin/$branch"
  git pull origin "$branch"
}

function gshow {
  git log --pretty=format:"%h" --grep "$1" | xargs git show
}
# -----------------------------------------------------------------------------


# ORG / SYSTEM / REPO
# -----------------------------------------------------------------------------

##
# org: switch organization context
#
# The org() function provides the switching mechanism. Actual org definitions
# are provided by the private repo via the _org_data() lookup function and
# ORG_LIST variable.
#
# Private repo must define:
#   ORG_LIST  - space-separated list of org aliases (e.g. "shb acme")
#   _org_data - function that echoes "prompt_color:gh_org:aws_prefix" for a
#               given alias, or returns 1 if unknown.
#
# Example:
#   ORG_LIST="shb acme"
#   function _org_data {
#     case "$1" in
#       shb)  echo "B_CYAN:sbaxter:" ;;
#       acme) echo "B_YELLOW:AcmeCorp:ACME" ;;
#       *)    return 1 ;;
#     esac
#   }
##
function org {
  test -n "$1" || { echo "usage: org <name>" >&2; return 1; }

  local name="$1"

  local def
  def=$(_org_data "$name" 2>/dev/null) || {
    echo "unknown org: $name" >&2
    echo "available: $ORG_LIST" >&2
    return 1
  }

  local color gh_org aws_prefix
  IFS=':' read -r color gh_org aws_prefix <<< "$def"

  export ORG="$name"
  export GH_ORG="$gh_org"
  export SYSTEM=""
  export USER_TAG="(\[${!color}\]${name}\[${NO_COLOR}${PROMPT_COLOR}\])"

  # AWS credential switching (if aws_prefix is set)
  if test -n "$aws_prefix"; then
    local id_var="${aws_prefix}_AWS_ACCESS_KEY_ID"
    local secret_var="${aws_prefix}_AWS_SECRET_ACCESS_KEY"
    export AWS_ACCESS_KEY_ID="${!id_var}"
    export AWS_SECRET_ACCESS_KEY="${!secret_var}"
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_REGION=$AWS_DEFAULT_REGION
    unset AWS_SESSION_TOKEN
  fi
}

# tab completion for org
function _org_complete {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  # shellcheck disable=SC2207
  COMPREPLY=( $(compgen -W "$ORG_LIST" -- "$cur") )
  return 0
}
complete -F _org_complete org
##


##
# sys: set or clear the system (repo grouping) context
function sys {
  if test -z "$1"; then
    export SYSTEM=""
    return
  fi

  local target="$REPO/$GH_ORG/$1"
  if test -d "$target"; then
    export SYSTEM="$1"
  else
    echo "system not found: $target" >&2
    return 1
  fi
}

# tab completion for sys
function _sys_complete {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local base="$REPO/$GH_ORG"
  test -d "$base" || return 0
  # shellcheck disable=SC2207
  COMPREPLY=( $(compgen -W "$(find "$base" -mindepth 1 -maxdepth 1 -type d \
    -exec basename {} \;)" -- "$cur") )
  return 0
}
complete -F _sys_complete sys
##


##
# repo: navigate to a repository
#   repo                     cd to $REPO/$GH_ORG/[$SYSTEM/]
#   repo <name>              cd to $REPO/$GH_ORG/[$SYSTEM/]<name>
#   repo <system>/<name>     cd to $REPO/$GH_ORG/<system>/<name> (inline)
function repo {
  local target="$REPO/$GH_ORG"
  test -n "$SYSTEM" && target="$target/$SYSTEM"

  if test -n "$1"; then
    if test "${1#*/}" != "$1"; then
      # slash detected — inline system/repo
      target="$REPO/$GH_ORG/$1"
    else
      target="$target/$1"
    fi
  fi

  cd "$target" || return
}

# tab completion for repo
function _repo_complete {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local base="$REPO/$GH_ORG"

  if test -n "$SYSTEM"; then
    base="$base/$SYSTEM"
  fi

  # support inline system/repo completion
  if test "${cur#*/}" != "$cur"; then
    local sys="${cur%%/*}"
    local partial="${cur#*/}"
    local sysdir="$REPO/$GH_ORG/$sys"
    test -d "$sysdir" || return 0
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -P "$sys/" -W "$(find "$sysdir" -mindepth 1 -maxdepth 1 \
      -type d -exec basename {} \;)" -- "$partial") )
  else
    test -d "$base" || return 0
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "$(find "$base" -mindepth 1 -maxdepth 1 -type d \
      -exec basename {} \;)" -- "$cur") )
  fi
  return 0
}
complete -F _repo_complete repo
##


##
# gclone: clone a repo into the org/system directory structure
#   gclone <remote>               clone as remote name
#   gclone <remote> <local-name>  clone as local-name
function gclone {
  test -n "$1" || { echo "usage: gclone <remote> [local-name]" >&2; return 1; }
  test -n "$GH_ORG" || { echo "GH_ORG not set. run org first." >&2; return 1; }

  local remote="$1"
  local localName="${2:-$remote}"
  local dest="$REPO/$GH_ORG"

  test -n "$SYSTEM" && dest="$dest/$SYSTEM"
  mkdir -p "$dest"

  git clone "git@github.com:$GH_ORG/$remote" "$dest/$localName" \
    && cd "$dest/$localName" || return
}
# -----------------------------------------------------------------------------


# GPG
# -----------------------------------------------------------------------------
function encryptfilefor {
  gpg --armor --encrypt --recipient "$1" < "$2" > "$2.gpg"
}

function sign {
  gpg --armor --detach-sign "$1"
}
# -----------------------------------------------------------------------------


# PROCESS
# -----------------------------------------------------------------------------
function isrunning {
  #shellcheck disable=SC2009
  ps -ef | grep -i "$1" | grep -v grep
}

function wpid {
  #shellcheck disable=SC2009
  ps -ef | grep -i "$1" | grep -v grep | awk '{print $2}'
}

function listenports {
  lsof | grep LISTEN
}
# -----------------------------------------------------------------------------


# TEXT PROCESSING
# -----------------------------------------------------------------------------
function dedup {
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' "$1"
}

function upcase {
  sed -i 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' "$1"
}

function downcase {
  sed -i 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' "$1"
}

function unDOS {
  sed -i 's/.$//' "$1"
}

function noextraspaces {
  sed -i 's/^[ \t]*//;s/[ \t]*$//' "$1"
}

function trailingspaces {
  sed -i '' -e's/[ \t]*$//' "$1"
}

function trails {
  local file="$1"
  test -f "$file" || return 1
  sed -i '' 's/[[:space:]]*$//' "$file"
}

function trailsall {
  for file in $(git ls-files --exclude-standard); do
    trails "$file"
  done
}
# -----------------------------------------------------------------------------


# NETWORK
# -----------------------------------------------------------------------------
function internalip {
  if test "$(uname -s)" = Darwin; then
    ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
  else
    hostname -I 2>/dev/null | awk '{print $1}'
  fi
}

function externalip {
  curl --silent checkip.amazonaws.com
}
# -----------------------------------------------------------------------------


# URL ENCODE/DECODE
# -----------------------------------------------------------------------------
function urlencode {
  local old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "%c" "$c" ;;
      *) printf '%%%02X' "'$c" ;;
    esac
  done

  LC_COLLATE=$old_lc_collate
}

function urldecode {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}
# -----------------------------------------------------------------------------


# FILE/DIRECTORY
# -----------------------------------------------------------------------------
function lookat {
  vim -R "$1"
}

function follow {
  cat "$1" && tail -f -n0 "$1"
}

function linecount {
  grep -c $ "$1"
}

function howbigis {
  test -z "$1" && echo "no file specified" && return;
  test -f "$1" || test -d "$1" || { echo "$1 not found" && return; }
  du -sh "$1" | awk '{print $1}'
}

if test "$(uname -s)" = Darwin; then
  function pb {
    pbcopy < "$1"
  }
  function pbclear {
    pbcopy < /dev/null
  }
  _alias pc || alias pc="tr -d '\n' | pbcopy"
fi

function l80 {
  local pattern=.
  local recursive=--recursive
  if test -n "$1"; then
    pattern="$1"
    recursive=
  fi
  grep --exclude-dir .git --line-number $recursive '.\{80\}' "$pattern"
}
# -----------------------------------------------------------------------------


# FILE COMPRESSION
# -----------------------------------------------------------------------------
if hash gnutar 2>/dev/null; then
  _alias tar || alias tar=gnutar
fi
# -----------------------------------------------------------------------------


# MARKDOWN
# -----------------------------------------------------------------------------
function mdfix {
  local file="$1"
  test -f "$file" || return 1
  awk '
  function is_list(line) {
    return (line ~ /^[[:space:]]*[-*][[:space:]]/ || line ~ /^[[:space:]]*[0-9]+\.[[:space:]]/)
  }
  function is_blank(line) {
    return (line ~ /^[[:space:]]*$/)
  }
  NR == 1 { prev = $0; next }
  {
    if (is_list($0) && !is_blank(prev) && !is_list(prev)) {
      print prev
      print ""
    } else {
      print prev
    }
    prev = $0
  }
  END { print prev }
  ' "$file" > "${file}.tmp" && mv -f "${file}.tmp" "$file"
}

function fixmd {
  for file in $(git ls-files --exclude-standard --modified --others '*.md'); do
    mdfix "$file"
    trails "$file"
  done
}

function mdfixall {
  for file in $(git ls-files --exclude-standard '*.md'); do
    mdfix "$file"
  done
}
# -----------------------------------------------------------------------------


# PACKAGE MANAGER
# -----------------------------------------------------------------------------
if test "$(uname -s)" = Darwin; then
  brew=/opt/homebrew/bin/brew
  test -x $brew || brew=/usr/local/bin/brew
  if test -x $brew; then
    eval "$($brew shellenv)"
    alias brup="brew upgrade && brew cleanup"
  fi
elif type apt-get >/dev/null 2>&1; then
  alias brup="sudo apt-get update && sudo apt-get upgrade"
elif type yum >/dev/null 2>&1; then
  alias brup="sudo yum update"
elif type pacman >/dev/null 2>&1; then
  alias brup="sudo pacman -Syu"
fi
# -----------------------------------------------------------------------------


# JAVA
# -----------------------------------------------------------------------------
test -f /usr/libexec/java_home || true
test -f /usr/libexec/java_home && JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
export JAVA_HOME
# -----------------------------------------------------------------------------


# COMPLETIONS
# -----------------------------------------------------------------------------
! type aws_completer >/dev/null 2>&1 || complete -C aws_completer aws
# -----------------------------------------------------------------------------
