# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

### COLORS ###
          RED="\[\033[0;31m\]"
    LIGHT_RED="\[\033[1;31m\]"
       YELLOW="\[\033[1;33m\]"
       ORANGE="\[\033[0;33m\]"
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

function prompt_git() {
  local status output flags
  status="$(git status 2>/dev/null)"
  [[ $? != 0 ]] && return;
  output="$(echo "$status" | awk '/# Initial commit/ {print "(init)"}')"
  [[ "$output" ]] || output="$(echo "$status" | awk '/# On branch/ {print $4}')"
  [[ "$output" ]] || output="$(git branch | perl -ne '/^\* (.*)/ && print $1')"
  flags="$(
    echo "$status" | awk 'BEGIN {r=""} \
      /^# Changes to be committed:$/        {r=r "+"}\
      /^# Changes not staged for commit:$/  {r=r "!"}\
      /^# Untracked files:$/                {r=r "?"}\
      END {print r}'
  )"
  if [[ "$flags" ]]; then
    output="$output$flags"
  fi
  echo "[$output]"
}

HOSTNAME="unknown"
function prompter {
	PS1="$BLUE\n$(prompt_git)$RED[$HOSTNAME:\w]:\e[m "
}
PROMPT_COMMAND="prompter"

#git completion
source ~/.git-completion.bash

# User specific aliases and functions
alias rm='rm -i '
alias cp='cp -i '
alias mv='mv -i '

alias ll="ls -l "
alias vi="vim "

#git specific aliases
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

alias got='git '
alias get='git '

function my
{
  chown `whoami`:`whoami` $1
}

function title
{
  echo -ne "\033]2;$1\007"
}

function findstr
{
  grep -i -n -R $1 * | grep -v ".svn" | less
}

function dojob
{
  source ~/.jobs/$1 
}

function upcase
{
  sed -i 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' $1
}

function downcase
{
  sed -i 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' $1
}

function setclock
{
  rdate -s 129.6.15.28
}

function owner ()
{
  chown -R $1 *
  chgrp -R $1 *
}

function addtotar ()
{
  tar -rf $1 $2
}

function reload
{
  source ~/.bashrc
}

function start
{
  /etc/init.d/$1 start
}

function restart
{
  /etc/init.d/$1 restart
}

function stop
{
  /etc/init.d/$1 stop
}

function isrunning
{
  ps -ef | grep $1 | grep -v grep
}

function specificcloseport
{
  iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport $1 -s $2 -j ACCEPT
}

function specificopenport
{
  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $1 -s $2 -j ACCEPT
}

function openport
{
  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $1 -j ACCEPT
}

function closeport
{
  iptables -D INPUT -p tcp -m state --state NEW -m tcp --dport $1 -j ACCEPT
}

function listenports
{
  lsof | grep LISTEN
}

function linecount
{
  cat "$1" | grep -c $ 
}

function unDOS
{
  sed -i 's/.$//' $1
}

function noextraspaces
{
  sed -i 's/^[ \t]*//;s/[ \t]*$//' $1
}

function notrailinglines
{
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' $1
}

function noHTML
{
  sed -i -e :a -e 's/<[^>]*>//g;/</N;//ba' $1
}

function isinstalled
{
  rpm -qa | grep -i $1
}

function tardate
{
  DUMPDATE=`date +%F-%H-%M`;
  tar -vcf ~/$1.$DUMPDATE.tar *
}

function unspacefilenames
{
  for f in *; do mv "$f" `echo $f | tr ' ' '_'`; done
}

function clonedirsfrom
{
  (cd $1; find -type d ! -name .) | xargs mkdir
}

function findtexti
{
  grep -n -i -R "$1" * | grep -v svn | grep -v "Binary file"
}

function findtext
{
  grep -n -R "$1" * | grep -v svn | grep -v "Binary file"
}

function wipe
{
  rm -R -f $1
}

function phperrors
{
  tail -100 /var/log/httpd/error_log
}

function reassign
{
  if [ -z $1 ]; then
   read -p "Give the name of the link: " linkname
  fi  
  if [ -z $2 ]; then
   read -p "Give the name of the new target: " target
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

function symlink
{
# $1 is the name of some directory to be replaced by a symlink.
# $2 is the name of directory we want to symlink to, instead.
  mv $1 $1.bak
  ln -s $2 $1
  rmdir $1.bak
}

function findtextinfiles {
 find . -name "$1" | xargs grep -n "$2" 
}

function save {
 mv $1 $1.saved 
}

function restore {
 mv $1.saved $1 
}

function copythisdirto
{
  cp -r -p -P -u * $1
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

function follow {
 cat $1; tail -F $1 & 
} 

function dedup {
 sed -i '$!N; /^\(.*\)\n\1$/!P; D' $1 
}

function taritup {
  dirname `pwd` > x
  tr x / -
  tarballname=`cat x`
  now=`date +%F`
  tar -zcf ~/$tarball.$now.tar.gz *
}

function untar
{
  FT=$(file -b $1 | awk '{print $1}')
	  if [ "$FT" = "bzip2" ]; then
			tar xvjf "$1"
		elif [ "$FT" = "gzip" ]; then
			tar xvzf "$1"
		fi
}

function back
{
  cd $OLDPWD
}

function lodev {
  cd /Library/WebServer/Documents
}

function dirs
{
  ls -l | grep ^d
}

#minification
function minime {
  java -jar /Applications/Java/yuicompressor-2.4.7/build/yuicompressor-2.4.7.jar $1 -o $2
}

#less and then minify ($1 = project name)
function lessmin {
  lessc less/$1.less > $1-style.css
  java -jar /Applications/Java/yuicompressor-2.4.7/build/yuicompressor-2.4.7.jar $1-style.css -o $1-style.min.css
}

