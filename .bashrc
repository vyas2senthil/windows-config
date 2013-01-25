export PATH=/bin:"$PATH"
export HISTCONTROL="ignoredups"
export HISTIGNORE="bg:fg:exit"
alias ls='ls -hF --color=tty --show-control-chars --block-size=1'                 # classify files in colour
alias dir='ls --color=auto --format=vertical --show-control-chars'
alias vdir='ls --color=auto --format=long --show-control-chars'
alias ll='ls -l --show-control-chars'                              # long list
alias la='ls -A --show-control-chars'                              # all but . and ..
alias l='ls -CFl --show-control-chars --block-size=1'                              #
alias vi=vim
export HISTSIZE=2000
export HISTFILESIZE=2000
. ~/.bashrc-public

if test `uname` = CYGWIN_NT-5.1 -o `uname` = CYGWIN_NT-6.1
then
    . ~/.bashrc-windows
else
    . ~/.bashrc-linux
fi

case $- in
    *i*) . ~/.bashrc-interactive;;
esac

alias svngdiff='svn diff --diff-cmd ~/bin/svntkdiff'
export DISPLAY=${DISPLAY:-:0} #if it is already set...
export USER=`whoami`
export USE_CCACHE=1
if test -e ~/.bash-path; then
    if test -z "$RECURSIVE_SHELL"; then
        . ~/.bash-path
    fi
else
    if test -d ~/etc/path/$(uname)-$(uname -m); then
        rm -rf ~/external/etc/overide/
        export PATH=$(
            builtin cd ~/etc/path/$(uname)-$(uname -m);
            for x in $(for d in *; do echo $d; done|sort -n); do
                readlink -m $x; 
            done|tr '\n' ':'
        )
    fi
    export PATH=$(echo -n $PATH|perl -npe 's,/+:,:,g'|tr ':' '\n'|uniq-even-non-ajacent |tr '\n' ':')
    printf 'export PATH=%q' "$PATH" > ~/.bash-path
fi
if test "$TERM" = dumb; then
    . ~/.bashrc-in-emacs
else
    . ~/.bashrc-no-emacs
fi
DEBEMAIL="baohaojun@gmail.com"
DEBFULLNAME="Bao Haojun"
export DEBEMAIL DEBFULLNAME

if test "$USER" = bhj; then
    export PERL_LOCAL_LIB_ROOT="/home/bhj/perl5";
    export PERL_MB_OPT="--install_base /home/bhj/perl5";
    export PERL_MM_OPT="INSTALL_BASE=/home/bhj/perl5";
    export PERL5LIB="/home/bhj/perl5/lib/perl5/x86_64-linux-gnu-thread-multi:/home/bhj/perl5/lib/perl5:$PERL5LIB";
    export PATH="/home/bhj/perl5/bin:$PATH";
fi
