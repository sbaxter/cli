# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
test -f /etc/bashrc  && source /etc/bashrc
test -f $HOME/.bash_private && source $HOME/.bash_private

# COLORS
# -------------------------------------------------------------------------
          RED="\[\033[0;31m\]"
    LIGHT_RED="\[\033[1;31m\]"
       YELLOW="\[\033[0;33m\]"
 LIGHT_YELLOW="\[\033[1;33m\]"
         BLUE="\[\033[0;34m\]"
   LIGHT_BLUE="\[\033[1;34m\]"
        GREEN="\[\033[0;32m\]"
  LIGHT_GREEN="\[\033[1;32m\]"
         CYAN="\[\033[0;36m\]"
   LIGHT_CYAN="\[\033[1;36m\]"
       PURPLE="\[\033[0;35m\]"
 LIGHT_PURPLE="\[\033[1;35m\]"
        WHITE="\[\033[1;37m\]"
   LIGHT_GRAY="\[\033[0;37m\]"
        BLACK="\[\033[0;30m\]"
         GRAY="\[\033[1;30m\]"
     NO_COLOR="\[\e[0m\]"

# Background Colors
     ON_BLACK="\033[40m"
       ON_RED="\033[41m"
     ON_GREEN="\033[42m"
    ON_YELLOW="\033[43m"
      ON_BLUE="\033[44m"
    ON_PURPLE="\033[45m"
      ON_CYAN="\033[46m"
     ON_WHITE="\033[47m"

# Directory Colors
export LS_COLORS='di=0;32'
# -------------------------------------------------------------------------


# DEFAULTS (stick them in .bash_profile)
# -------------------------------------------------------------------------
: ${PROMPT_COLOR:=$YELLOW}
: ${REPO:=~/repos}
: ${WWW_HOME:=https://google.com}
: ${AWS_ACCOUNT_TAG:=}
# -------------------------------------------------------------------------


# TERMINAL
# -------------------------------------------------------------------------
# VI mode for editing the command line.
set -o vi

export VISUAL=vim
export EDITOR=$VISUAL
export GIT_EDITOR=vim

# cmd history
export HISTCONTROL=erasedups:ignoreboth
export HISTFILESIZE=500000
export HISTSIZE=100000
export HISTIGNORE="&:[ ]*:exit"
shopt -s histappend
shopt -s cmdhist

function reload {
  source ~/.bashrc
}

function title {
  echo -ne "\033]2;$1\007"
}

function setclock {
  rdate -s time.nist.gov
}

function _gbranch {
  local sym=$(git symbolic-ref HEAD 2>/dev/null)
  [ -z $sym ] && sym=$(git describe --contains --all HEAD)
  [ -z $sym ] && sym=$(git rev-parse --short HEAD)
  echo ${sym##refs/heads/}
}

function _gprompt {
  local output branch w i u
  git status >/dev/null 2>&1 || return;

  branch=$(_gbranch)
  w=$(git diff --no-ext-diff --quiet --exit-code || echo "!")
  i=$(git diff-index --cached --quiet HEAD -- || echo "+")
  u=$([ -z $(git ls-files --others --exclude-standard) >/dev/null 2>&1 ] || echo "?")

  echo "[$branch$CYAN$w$i$u$PROMPT_COLOR]"
}

function _prompt {
  local depth=$(echo `pwd` | sed 's/[^/]//g' | sed 's/^\///')
  PS1="$PROMPT_COLOR\n$(_gprompt)$PROMPT_COLOR[$HOSTNAME$AWS_ACCOUNT_TAG:$depth\W]:$NO_COLOR "
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
alias vi="vim "
alias grep="grep --color=auto"
alias back="cd -"
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."
alias lynx="lynx -accept_all_cookies -vikeys"
# -------------------------------------------------------------------------


# GIT
# -------------------------------------------------------------------------

# git completion
test -f $HOME/.git-completion.bash && source $HOME/.git-completion.bash

# aliases
alias hist='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias gst='git status '
alias ga='git add '
alias gc='git commit -S'
alias gr='git pull --rebase'
alias gd='git diff'
alias go='git checkout '
alias gpt='git push --tags'
alias gpr='git merge --no-ff'
alias grb="git for-each-ref --sort=-committerdate refs/remotes/ --format='%(refname:short)' --count=10"
alias groot='cd $(git rev-parse --show-cdup) '

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
  cd $REPO/$1
}

# auto-complete for repo
_repo_dir () {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}
  if [ $COMP_CWORD -eq 1 ]; then
      COMPREPLY=( $( compgen -W "$(cd "$REPO" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)" -- $cur ) )
  elif [ $COMP_CWORD -eq 2 ]; then
      COMPREPLY=( $( compgen -W "$(cd "$REPO/$prev" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)" -- $cur ) )
  fi
  return 0
}
complete -F _repo_dir repo

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


# PROCESS MGMT
# -------------------------------------------------------------------------
function dojob {
  source ~/.jobs/$1
}

function start {
  /etc/init.d/$1 start
}

function restart {
  /etc/init.d/$1 restart
}

function stop {
  /etc/init.d/$1 stop
}

function isrunning {
  ps -ef | grep -i $1 | grep -v grep
}

function isinstalled {
  rpm -qa | grep -i $1
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
  curl ifconfig.me
}
# -------------------------------------------------------------------------


# DIRECTORY AND FILE
# -------------------------------------------------------------------------
function lookat {
  vim -R $1
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

function pb {
#OSX only:
  cat $1 | pbcopy
}
alias pc="tr -d '\n' | pbcopy"

function howbigis {
  # Quickly nab a human readable file size
  [ -z "$1" ] && echo "howbigis: no file specified" && return;
  [ ! -f "$1" ] && echo "howbigis: $1 not found" && return;

  ls -lah "$1" | awk '{print $5}'
}
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
# Specify gnutar (for MacOSX)
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
  if [ -z $1 ]; then
   read -p "Give the name of the link: " linkname
  fi
  if [ -z $2 ]; then
   read -p "Give the name of the new target: " targe
  fi

  # Make sure the thing we are removing is a sym link.
  if [ ! -L $1 ]; then
   echo "Sorry. $1 is not a symbolic link"

  # attempt to create the file if it does not exist.
  else
   if [ ! -e $2 ]; then
     touch $2
     # mention the fact that we had to create it.
     echo "Created empty file named $2"
   fi

   # make sure the target is present.
   if [ ! -e $2 ]; then
     echo "Unable to find or create $2."
   else
     # nuke the link
     rm -f $1
     # link
     ln -s $2 $1
     # confirm by showing.
     ls -l $1
   fi
  fi
}
# -------------------------------------------------------------------------
