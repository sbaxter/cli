# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
test -f /etc/bashrc  && source /etc/bashrc
test -f $HOME/.bash_private && source $HOME/.bash_private

# COLORS
# -------------------------------------------------------------------------
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

# Directory Colors
export LS_COLORS='di=0;32'
# -------------------------------------------------------------------------


# DEFAULTS (stick them in .bash_profile)
# -------------------------------------------------------------------------
: ${PROMPT_COLOR:=$YELLOW}
: ${ORG:=}
: ${REPO:=~/repos}
: ${WWW_HOME:=https://google.com}
: ${USER_TAG:="($USER)"}
# -------------------------------------------------------------------------


# TERMINAL
# -------------------------------------------------------------------------
# vi mode for editing the command line.
set -o vi

# vi as the default editor.
export VISUAL=vim
export EDITOR=$VISUAL
export GIT_EDITOR=$VISUAL

# Add bin files to $PATH
_bashrc="${BASH_SOURCE[0]}"
[ -h "$_bashrc" ] && export PATH=$PATH:$(dirname $(readlink $_bashrc))/bin
[ -h "$_bashrc" ] && export VI_CONFIG=$(dirname $(readlink $_bashrc))/vi

# cmd history
export HISTCONTROL=erasedups:ignoreboth
export HISTFILESIZE=500000
export HISTSIZE=100000
export HISTIGNORE="&:[ ]*:exit"
shopt -s histappend
shopt -s cmdhist

function reload {
  source $HOME/.bashrc
}

function title {
  echo -ne "\033]2;$1\007"
}

function setclock {
  rdate -s time.nist.gov
}
# -------------------------------------------------------------------------


# PROMPT
# -------------------------------------------------------------------------
function _gbranch {
  local sym=$(git symbolic-ref HEAD 2>/dev/null)
  [ -z $sym ] && sym=$(git describe --contains --all HEAD)
  [ -z $sym ] && sym=$(git rev-parse --short HEAD)
  echo ${sym##refs/heads/}
}

function _gprompt {
  local output branch w i u
  git status >/dev/null 2>&1 || return;

  if git log >/dev/null 2>&1; then
    branch=$(_gbranch)
    i=$(git diff-index --cached --quiet HEAD -- 2>/dev/null || echo "+")
  else
    branch='(init)'
    i=$(git diff --cached --quiet --exit-code || echo "+")
  fi

  w=$(git diff --no-ext-diff --quiet --exit-code || echo "!")
  u=$([ -z $(git ls-files --others --exclude-standard -- ':/*') >/dev/null 2>&1 ] || echo "?")

  echo "[$branch$CYAN$w$i$u$PROMPT_COLOR]"
}

function _prompt {
  local depth=$(echo `pwd` | sed 's/[^/]//g' | sed 's/^\///')
  PS1="$NO_COLOR$PROMPT_COLOR\n$(_gprompt)$PROMPT_COLOR[$HOSTNAME$USER_TAG:$depth\W]:$ON_BLACK$NO_COLOR "
  PS2="   $PROMPT_COLOR->$NO_COLOR "
}
PROMPT_COMMAND="_prompt"
# -------------------------------------------------------------------------


# ALIASES
# -------------------------------------------------------------------------
alias rm='rm -i '
alias cp='cp -i '
alias mv='mv -i '
alias ll="ls -l "
alias lla="ls -al"
alias vi="vim "
alias grep="grep --color=auto"
alias back="cd -"
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."
alias lynx="lynx -accept_all_cookies -vikeys"
alias mfa="source source-aws-mfa"

# aws regions
for region in us-east-1 us-east-2 us-west-2 us-west-1 ap-northeast-1 \
ap-northeast-2 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 ap-south-1; do
  alias $region="export AWS_DEFAULT_REGION=$region"
done
# -------------------------------------------------------------------------


# GIT
# -------------------------------------------------------------------------

# git completion
test -f $HOME/.git-completion.bash && source $HOME/.git-completion.bash

# aliases
alias hist='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gpick='git cherry-pick -x'
alias gd='git diff'
alias gco='git checkout'
alias gpr='git merge --no-ff'
alias gpt='git push --tags'
alias gr='git pull --rebase'
alias grb="git for-each-ref --sort=-committerdate refs/remotes/ --format='%(refname:short)' --count=10"
alias grm='git rm'
alias groot='cd $(git rev-parse --show-cdup) '
alias gt='git tag -sam'

function gp {
  local branch
  git status >/dev/null 2>&1 || return;

  branch=$(git symbolic-ref HEAD 2>/dev/null)
  [ -z $branch ] && echo "Detached state?" && return 1
  echo "pushing to origin/$branch"
  git push origin $branch
}

function gu {
  local branch
  git status >/dev/null 2>&1 || return;

  branch=$(git symbolic-ref HEAD 2>/dev/null)
  [ -z $branch ] && echo "Detached state?" && return 1
  echo "pulling from origin/$branch"
  git pull origin $branch
}
# -------------------------------------------------------------------------


# REPOS
# -------------------------------------------------------------------------
function repo {
  [ -z "$ORG" ] && cd $REPO/$1 || cd $REPO/$ORG/$1
}

# auto-complete for repo
_repo_dir () {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}
  if [ $COMP_CWORD -eq 1 ]; then
      COMPREPLY=( $( compgen -W "$(cd "$REPO/$ORG" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)" -- $cur ) )
  elif [ $COMP_CWORD -eq 2 ]; then
      COMPREPLY=( $( compgen -W "$(cd "$REPO/$ORG/$prev" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)" -- $cur ) )
  fi
  return 0
}
complete -F _repo_dir repo

alias wip="cd $REPO/wip"

function towip {
  mv $1 $REPO/wip/.
}

function gclone {
  [ -z $1 ] && echo "give me a repo to clone" && return
  cd $REPO
  git clone git@github.com:$1
  cd $(echo $1 | sed 's/^.*\///')
}
# -------------------------------------------------------------------------


# EMACS
# -------------------------------------------------------------------------
function e {
  [[ -z $1 || -d $1 ]] && echo "slow down!" && return 1

  [[ ! -f $1 ]] && echo -n "create? (y/N) " && read c

  [[ -n "$c" && "$c" = "y" ]] && touch $1

  [[ -f $1 ]] && emacs $1 || return 1
}
# -------------------------------------------------------------------------


# GPG
# -------------------------------------------------------------------------
function encryptfilefor {
  gpg -a --encrypt --recipient $1 < $2 > $2.gpg
}

function sign {
  gpg -a --detach-sign "$1"
}
# -------------------------------------------------------------------------


# PROCESS/PKG MGMT
# -------------------------------------------------------------------------
if [ `uname -s` != 'Darwin' ]; then
  function start {
    /etc/init.d/$1 start
  }

  function restart {
    /etc/init.d/$1 restart
  }

  function stop {
    /etc/init.d/$1 stop
  }

  function isinstalled {
    rpm -qa | grep -i $1
  }
fi

function isrunning {
  ps -ef | grep -i $1 | grep -v grep
}

# -------------------------------------------------------------------------


# SED
# -------------------------------------------------------------------------
function dedup {
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' $1
}

function upcase {
  sed -i 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' $1
}

function downcase {
  sed -i 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' $1
}

function unDOS {
  sed -i 's/.$//' $1
}

function noextraspaces {
  sed -i 's/^[ \t]*//;s/[ \t]*$//' $1
}

function notrailinglines {
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' $1
}

function noHTML {
  sed -i -e :a -e 's/<[^>]*>//g;/</N;//ba' $1
}

function trailingspaces {
  sed -i '' -e's/[ \t]*$//' $1
}

function doublespace {
  sed -i 'G' $1
}

function safedoublespace {
  sed -i '/^$/d;G' $1
}

function singlespace {
  sed -i 'n;d' $1
}

function blanklinebefore {
  sed -i "/$1/{x;p;x;}" $2
}

function blanklineafter {
  sed -i "/$1/G" $2
}

function reverseline {
  sed -i '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' $1
}

function appendlines {
  sed -e :a -e -i '/\\$/N; s/\\\n//; ta' $1
}
# -------------------------------------------------------------------------


# PORTS
# -------------------------------------------------------------------------
if [ `uname -s` != 'Darwin' ]; then
  function specificcloseport {
    iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport $1 -s $2 -j ACCEPT
  }

  function specificopenport {
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $1 -s $2 -j ACCEPT
  }

  function openport {
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $1 -j ACCEPT
  }

  function closeport {
    iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport $1 -j ACCEPT
  }
fi

function listenports {
  lsof | grep LISTEN
}
# -------------------------------------------------------------------------


# NET
# -------------------------------------------------------------------------
function internalip {
 ifconfig \
    | grep -B1 "inet addr" \
    | awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' \
    | awk -F: '{ print $1 ": " $3 }';
}

function externalip {
  curl checkip.amazonaws.com
}
# -------------------------------------------------------------------------


# DIRECTORY AND FILE
# -------------------------------------------------------------------------
function lookat {
  vim -R $1
}

function follow {
  cat $1 && tail -f -n0 $1
}

function findtextinfiles {
  find . -name "$1" | xargs grep -n "$2"
}

function linecount {
  cat "$1" | grep -c $
}

function ldir {
  ls -l | grep ^d
}

function unspacefilenames {
  if [ -z "$1" ]; then
    for f in *; do mv "$f" `echo $f | tr ' ' '_'`; done
  else
    mv "$1" `echo "$1" | tr ' ' '_'`
  fi
}

function clonedirsfrom {
  (cd $1; find -type d ! -name .) | xargs mkdir
}

function copythisdirto {
  cp -r -p -P -u * $1
}

function howbigis {
  [ -z "$1" ] && echo "no file specified" && return;
  [ ! -f "$1" ] && echo "$1 not found" && return;

  ls -lah "$1" | awk '{print $5}'
}

if [ `uname -s` = 'Darwin' ]; then
  function pb {
    cat $1 | pbcopy
  }
  alias pc="tr -d '\n' | pbcopy"
fi
# -------------------------------------------------------------------------


# FILE PERMISSIONS
# -------------------------------------------------------------------------
function my {
  chown `whoami`:`whoami` $1
}

function owner () {
  chown -R $1 *
  chgrp -R $1 *
}
# -------------------------------------------------------------------------


# FILE COMPRESSION
# -------------------------------------------------------------------------
if hash gnutar 2>/dev/null; then
  alias tar='gnutar'
fi

function addtotar () {
  tar -rf $1 $2
}
# -------------------------------------------------------------------------


# SYM LINK
# -------------------------------------------------------------------------
function reassign {
  [ ! -L $1 ] && { echo "$1 is not a symbolic link."; return 1; }
  [ ! -e $2 ] && { touch $2; echo "created empty file named $2"; }
  [ ! -e $2 ] && { echo "unable to create $2"; return 1; }

  rm -f $1
  ln -s $2 $1
  ls -l $1
}
# -------------------------------------------------------------------------
