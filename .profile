# $Id: profile,v 1.60 2008/12/04 19:52:28 holsta Exp $

# Interactive logins
# This .profile needs to work everywhere I have accounts:
# * OS X macbook 
# * My openbsd fileserver
# * The linux web host

# Needed for svn/iconv
LC_CTYPE=da_DK.ISO8859-1

export LC_CTYPE

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:/usr/local/git/bin/"
HOSTNAME="`hostname -s`"
TERM=xterm-color
LESSCHARSET=latin1
TZ=CET
export TERM HOME MAIL LESSCHARSET PATH TZ 

CVSUMASK=007
export CVSUMASK

unset MAILCHECK
unset HISTFILE

# ksh options; might fail on non-PD KSH shells.
if [ "/bin/ksh" = "$SHELL" ]; then
	set -o vi
	set -o vi-tabcomplete
	set -o trackall
else
	echo note: This is not the public domain ksh.
fi

# vi keybindings on my macbook, please.
if [ "/bin/bash" = "$SHELL" ]; then
	set -o vi
fi


# If vim is available, use it. Otherwise assume vi is.
if [ -x "`which vim`" ]; then 
	EDITOR=vim
else
	EDITOR=vi
	echo note: vim not available.
fi
export EDITOR

sshsock() {
	# Find SSH authentication sockets that belong to us,
	# and use the latest one.
	export SSH_AUTH_SOCK=`find /tmp/ -user $USER  \
	-name 'agent*' 2>/dev/null | xargs ls -t | head -1`
	# Did we find a ssh-agent socket?
	if [ -S "$SSH_AUTH_SOCK" ]; then
	    # We did. Try to use it.
	    echo -n "Found $SSH_AUTH_SOCK: "
	    ssh-add -l
	else
	   # Found no agent, invoke one and prompt for password.
	   eval `ssh-agent`
	   ssh-add
	fi
}

# If SSH_AUTH_SOCK is not set, we don't know of an ssh-agent to
# talk to. If SSH_CLIENT isn't set either, we're logged in
# locally (console or xdm) and we want an ssh-agent.
if [ -z "$SSH_AUTH_SOCK" ] && [ -z "$SSH_CLIENT" ]; then
	sshsock
fi

# copy files to temp location 
publish () {
	PUBLISHFILES=$*

	PUBLISHURL=http://a.mongers.org/x/
	PUBLISHHOSTNAME=katie.klen.dk
	PUBLISHPATH=/var/apache/holsta/a.mongers.org/x/

	if [ -z "$SSH_AUTH_SOCK" ] && [ -z "$SSH_CLIENT" ]; then
		sshsock
	fi

	for f in $PUBLISHFILES; do
		if [ ! -f $f ]; then
			echo "publish: $f not found."
			exit	
		fi
	done

	scp $PUBLISHFILES \
		$PUBLISHHOSTNAME:$PUBLISHPATH

	for i in $PUBLISHFILES; do
		k=$(basename $i)
		ssh $PUBLISHHOSTNAME 'chmod o+r $PUBLISHPATH$k'
		echo $PUBLISHURL$k
	done
}

# http://henrik.nyh.se/2008/12/git-dirty-prompt
# http://www.simplisticcomplexity.com/2008/03/13/show-your-git-branch-name-in-your-prompt/
#   username@Machine ~/dev/dir[master]$   # clean working directory
#   username@Machine ~/dev/dir[master*]$  # dirty working directory 
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ [\1$(parse_git_dirty)]/"
}
# Use my own PS1 
#export PS1='\h \[\033[1;33m\]\w\[\033[0m\]$(parse_git_branch)$ ' 

# turn the prompt red if the previous program exited with non-zero.
if type -p printf > /dev/null 2>&1; then
    red=$(printf '\e[31m')
    export PS1='$([ $? -eq 0 ]||printf $red)\h \w$(parse_git_branch)\$\[\e[0m\] '
else
    export PS1='\[\e[0m\]\h\ \w$(parse_git_branch)$\[\e[0m\] '
fi

openbsdspecific() {
	# Various openbsd-specific aliases 
	alias pkgup="sudo pkg_add -uiF update -F updatedepends"
	alias pkg_add="sudo pkg_add -i"
	alias osupgrade="cd ~/bin; sh osupgrade.sh"
	alias ports='sqlite3 /usr/local/share/sqlports'

	# Find a proper JRE
	if [ -x /usr/local/jre-1.7.0/ ]; then
		JAVA_HOME=/usr/local/jre-1.7.0/
		export JAVA_HOME
	fi
}

worldsync() {
	# Handy alias to run before going offline for a long time.
	# Lets me get the latest of everything while I sleep, pack the 
	# car, etc
	cd ~/work/
	for i in $(find . -maxdepth 1 -type d); do 
		if [ -x $i/CVS ]; then
			echo "[$i]"
			cd $i; cvs up; cd ..
		fi
		if [ -x $i/.git ]; then
			echo "[$i]"
			cd $i; git pull; cd ..
		fi
		if [ -x $i/.svn ]; then
			echo "[$i]"
			cd $i; svn up; cd ..
		fi
	done
}


alias ls="ls -F"
alias work="cd ~/work"		# shorthand for work dir

# make it easier to update mayas website
alias maya.mongers.org="ssh -t katie.klen.dk 'cd /var/apache/holsta/maya.mongers.org/htdocs/2009; svn up'"

# ssh session to files
alias files="ssh -t files.mongers.org 'tmux a'"
# make it easier to run rtorrent inside screen
stty start undef
stty stop undef

# Machine dependant stuff is called here
case "$HOSTNAME" in
	x40|files|gateway|mpd-stue)
		openbsdspecific
		;;
	katie)
		TERM=vt100
		export TERM
		;;		
esac
