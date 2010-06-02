#!/bin/bash
set -e
cd ~/windows-config/
for x in `git ls-tree --name-only HEAD`
do
    if test $x = . -o $x = .. -o $x = .git; 
    then
        continue;
    fi
    if test -e ~/$x -a "$(readlink -f ~/$x)" != "$(readlink -f ~/windows-config/$x)"; 
    then
        echo "Error: ~/$x already exist and it's not softlink to ~/windows-config/$x"
        mv ~/$x ~/$x.bak
        ln -s ~/windows-config/$x ~/
    elif ! test -h ~/$x;
    then
        ln -s ~/windows-config/$x ~/
    fi
done

if test `whoami` = bhj; then
    ln -sf ~/.gitconfig.`whoami` ~/.gitconfig
fi
echo OK
