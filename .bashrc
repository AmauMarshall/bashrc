# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto -n'
    alias fgrep='fgrep --color=auto -n'
    alias egrep='egrep --color=auto -n'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#ssh aliases
alias ssh-dev='ssh amarechal@10.10.11.241'
alias ssh-janus='ssh janus@10.10.10.50'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Personal preferences
alias cd..='cd ..'
alias cd.='cd /'


## Aptitude aliases
alias aptup='sudo apt update && sudo apt upgrade'
alias aptcl='sudo apt autoremove && sudo apt clean && sudo apt autoclean'
alias aptin='sudo apt install' 

## Bash aliases
alias hcl='rm -f ~/.bash_history && history -c'
alias brc='. ~/.bashrc'
alias vimbrc='vim ~/.bashrc'
alias subrc='subl ~/.bashrc'
alias cdbrc='cd /bashrc'

## Network aliases
alias reset-resolv='echo -e "nameserver 8.8.8.8\nsearch mobilisis.local" | sudo tee /etc/resolv.conf > /dev/null'


### DOCKER Stuff
alias dc='docker-compose'
alias dcres='dc down -v && dc up -d && dc logs -f'

### GIT Stuff
git-sparse-clone() {
	CURR_PATH=$(pwd)
	mkdir $2
	git clone --no-checkout $1 $2
	cd $2
	git sparse-checkout set $3 $4 $5
	git checkout
	cd $CURR_PATH
}
alias gc='git clone'
alias gsc='git-sparse-clone' 

### GStreamer Stuff
cam-stream() {
    gst-launch-1.0 -v v4l2src device=/dev/video0 ! videoconvert ! vp8enc ! rtpvp8pay ! udpsink host=$1 port=$2
}
alias camstr='cam-stream'
file-stream() {
    gst-launch-1.0 -v filesrc location=$3 ! decodebin ! videoconvert ! vp8enc ! rtpvp8pay ! udpsink host=$1 port=$2
}
alias filestr='file-stream'
alias kd='killall droidcam'
alias cam-on='droidcam-cli 10.10.30.51 4747'

### Vegeta stuff
vegeta-attack() {
    DATETIME=$(date +%F)_$(date +%T)
    DIR_NAME="/vegeta/attack_$DATETIME"
    mkdir "$DIR_NAME"
    touch "$DIR_NAME/$(echo "$1" | sed "s/\//_/g")"
    echo "$1" | vegeta attack -duration="$2"s -rate="$3" -timeout=60s -output="$DIR_NAME/attack_$DATETIME.log"
    cat "$DIR_NAME/attack_$DATETIME.log" | vegeta encode -to=json -output="$DIR_NAME/attack_$DATETIME.json"
    cat "$DIR_NAME/attack_$DATETIME.log" | vegeta encode -to=csv -output="$DIR_NAME/attack_$DATETIME.csv"
    cat "$DIR_NAME/attack_$DATETIME.log" | vegeta report -type=text -output="$DIR_NAME/report_$DATETIME.log"
    echo "$DIR_NAME/attack_$DATETIME.json"
    echo "$DIR_NAME/attack_$DATETIME.csv"
    echo "$DIR_NAME/report_$DATETIME.log"
}
alias vatt='vegeta-attack'
decode64() {
    cat $1 | cut -d',' -f7 | base64 --decode | sed -e "s/}/}\n/g"
}
vatt-cat() {
    vegeta-attack "$1" "$2" "$3" > res.txt
    cat $(cat res.txt | grep report)
    decode64 $(cat res.txt | grep csv)
    rm res.txt
}
alias cdvegeta='cd /vegeta/'


#### Dev VM
alias cdgit='cd /git'
alias cdshare='cd /mnt/share'
alias cdh='cd /home'

#### M2-dev VM
alias cdjanus='cd ~/projects/amr-janus/'
alias cdrm='cd ~/projects/amr-robot-module/'
alias cdhc='cd ~/projects/amr-health-check/'
