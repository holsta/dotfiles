# $Id: profile,v 1.60 2008/12/04 19:52:28 holsta Exp $

# Interactive logins
# This .profile needs to work everywhere I have accounts:
# * My openbsd laptop
# * My openbsd fileserver
# * The linux web host

# Needed for svn/iconv
export LC_CTYPE=da_DK.ISO8859-1

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:$JAVA_HOME/bin"
HOSTNAME="`hostname -s`"
TERM=xterm-color
LESSCHARSET=latin1
TZ=CET
export TERM HOME MAIL LESSCHARSET PATH TZ 

RSYNC_RSH=ssh
CVSUMASK=007
CVS_RSH=ssh
export RSYNC_RSH CVSUMASK CVS_RSH

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
		ssh $PUBLISHHOSTNAME chmod o+r $PUBLISHPATH$k
		echo $PUBLISHURL$k
	done
}

function show_ports {
	echo 'Network ports:'
	fstat -u holsta | grep internet | grep -v ssh | grep -v firefox | awk {'print "    " $2 "  " $9'}
	echo
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

if [ -x /usr/local/jre-1.7.0/ ]; then
	JAVA_HOME=/usr/local/jre-1.7.0/
	export JAVA_HOME
fi

openbsdspecific() {
OPENBSDVER=`sysctl kern.version`

OPENBSD_DK="ftp://ftp.eu.openbsd.org/pub/OpenBSD/"
PKG_STABLE_DIR="`uname -r`/packages/`machine`/"
PKG_CURRENT_DIR="snapshots/packages/`machine`/"
OS_STABLE_DIR="`uname -r`/`machine`/"
OS_CURRENT_DIR="snapshots/`machine`/"

PKG_STABLE=$OPENBSD_DK$PKG_STABLE_DIR
PKG_CURRENT=$OPENBSD_DK$PKG_CURRENT_DIR
OS_STABLE=$OPENBSD_DK$OS_STABLE_DIR
OS_CURRENT=$OPENBSD_DK$OS_CURRENT_DIR

# if kern.version contains -current
case "$OPENBSDVER" in
	*) PKG_PATH=$PKG_CURRENT
			OS_PATH=$OS_CURRENT
			;;
esac

export PKG_PATH OS_PATH

# Clean up our environment 
unset OPENBSD_DK PKG_STABLE_DIR PKG_CURRENT_DIR \
	OS_STABLE_DIR OS_CURRENT_DIR PKG_STABLE \
	PKG_CURRENT OS_STABLE OS_CURRENT OPENBSDVER

# Various openbsd-specific aliases 
alias pkgup="sudo pkg_add -uiF update -F updatedepends"
alias pkg_add="sudo pkg_add -i"
alias osupgrade="cd ~/bin; sh osupgrade.sh"
}


worldsync() {
	# Handy alias to run before going offline for a long time.
	# Lets me get the latest of everything while I sleep, pack the 
	# car, etc
	cd ~/work/
	for i in $(find . -maxdepth 1 -type d); do 
		if [ -x $i/CVS ]; then
			cd $i; cvs up; cd ..
		fi
		if [ -x $i/.git ]; then
			cd $i; git pull; cd ..
		fi
		if [ -x $i/.svn ]; then
			# skip svn repos for now
			cd $i; echo svn up; cd ..
		fi
	done
}


alias ls="ls -F"
alias gsxy="/home/holsta/work/siteXYtools/generate"
alias work="cd ~/work"		# shorthand for work dir

# tvix passwords are not secret and not changable, so tell the github people
# my tvix password, just to make life easier on myself.
alias tvix='shlight //tvix/tvixhd1 /mnt/tvix -U tvixhd1 -P tvixhd1'

# make it easier to update mayas website
alias maya.mongers.org="ssh katie.klen.dk 'cd /var/apache/holsta/maya.mongers.org/htdocs/2009; svn up'"

# make it easier to run rtorrent inside screen
stty start undef
stty stop undef


# Machine dependant stuff is called here
case "$HOSTNAME" in
	tori)
		openbsdspecific
		show_ports
		calendar -A 0
		;;
	fileserver)
		openbsdspecific
		;;
	gateway)
		openbsdspecific
		;;
	katie)
		TERM=vt100
		export TERM
		;;		
esac
