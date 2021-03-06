#!/usr/bin/env bash

##################################################################
# Define basic colors as a starting point:
if [ "$(uname)" == "Darwin" ]; then
    source ./dotfiles/bash_colors_Darwin
else
    source ./dotfiles/bash_colors_Linux
fi

##################################################################
# Show Warning:
WARNINGMSG="\t${BIRed}!!!WARNING!!!${Color_Off}\n
This script is ${BIRed}DESTRUCTIVE!${Color_Off} It overwrites
all your previous (dotfile) setup.
Press ${Cyan}<Ctrl+C>${Color_Off} NOW to cancel..."

INFO="${BIGreen}*INFO*,${Color_Off}"
WARN="${BIYellow}*WARN*,${Color_Off}"
ERR="${BIRed}*ERROR*,${Color_Off}"

echo -e "${WARNINGMSG}"
read cancel

##################################################################
# Install vital things:
case $(uname -s) in
    "Darwin")
        if ! hash brew 2>/dev/null; then
            echo -e "${ERR} Homebrew has to be installed before continuing!"
            exit
        fi
        brew install ruby --upgrade
        brew install emacs --upgrade
        brew install aspell --upgrade
        brew install git --upgrade

        ;;
    *) # Need to setup other installations here
        ;;
esac


##################################################################
# Prepare global variables
pathmunge () {
    if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}


##################################################################
# Setup Links:
SETUPDIR=`pwd`
cd ${HOME}
echo -e "${INFO} Removing the old dotfiles"
if [ -d ./dotfiles/ ]; then
    mv -f dotfiles dotfiles.old
fi
# if [ -d .emacs.d/ ]; then
#     mv .emacs.d .emacs.d~
# fi

##################################################################
# Change the C-h and C-?
ln -svf ${SETUPDIR}/dotfiles/xmodmap ${HOME}/.xmodmap
xmodmap ~/.xmodmap 
stty erase 


rm -v ${HOME}/.emacs.d
rm -v ${HOME}/.screenrc
rm -v ${HOME}/.bash_profile
rm -v ${HOME}/.bashrc*
rm -v ${HOME}/.bash_colors
rm -v ${HOME}/.tmux.conf

echo -e "${INFO} Creating soft links"
ln -sfv ${SETUPDIR}/dotfiles/screenrc           ${HOME}/.screenrc
ln -sfv ${SETUPDIR}/dotfiles/bash_profile       ${HOME}/.bash_profile
ln -sfv ${SETUPDIR}/dotfiles/bashrc             ${HOME}/.bashrc
ln -sfv ${SETUPDIR}/dotfiles/bashrc_custom      ${HOME}/.bashrc_custom
ln -sfv ${SETUPDIR}/dotfiles/tmux.conf		${HOME}/.tmux.conf

# ln -svf `which pygmentize-2.7`                        ${HOME}/bin/pygmentize  # Python highlighter

# Create basic MUTT setup if it doesn't exist:
# if [ ! -f ${HOME}/.muttrc ]; then
#     echo -e "${INFO} Creating basic MUTTRC"
#     echo -e "${WARN} Please, modify it!"
#     ln -sv ${SETUPDIR}/dotfiles/muttrc                ${HOME}/.muttrc
# fi

##################################################################
# Create color link:
if [ "$(uname)" == "Darwin" ]; then     # Mac
    ln -sfv     ${SETUPDIR}/dotfiles/bash_colors_Darwin ${HOME}/.bash_colors
else
    ln -sfv     ${SETUPDIR}/dotfiles/bash_colors_Linux  ${HOME}/.bash_colors
fi

##################################################################
# GIT:
echo -e "${INFO} Setting up GIT"
if [ -d ${HOME}/.git.OLD/ ]; then
    rm -rfv ${HOME}/.git.OLD
fi
mkdir ${HOME}/.git.OLD

# move .gitignore:
mv -fv  ${HOME}/.gitignore                      ${HOME}/.git.OLD/
ln -sv  ${SETUPDIR}/dotfiles/gitignore          ${HOME}/.gitignore

# create .gitconfig:
mv -v ${HOME}/.gitconfig ${HOME}/.git.OLD/
GITCONFIG="[include]
\tpath = ${SETUPDIR}/dotfiles/gitconfig"
echo -e "${GITCONFIG}" > ${HOME}/.gitconfig

# Create GIT user data:
GITUSER="[user]
\tname = \"\"
\temail = \"\"
[github]
\tuser =
\ttoken = "
if [ ! -f ${HOME}/.gitconfig_user ]; then
    echo -e "${GITUSER}" > ${HOME}/.gitconfig_user
else
    echo -e ".gitconfig_user exists!\n" # Don't everwrite the USER info - might have tokens

fi

# If the version of the git < 1.7.10, everything has to be pasted in the gitconfig :(
git_version=`git --version`
[[ $git_version =~ ([a-zA-Z ]+)([0-9\.]+) ]] # && echo "${BASH_REMATCH[2]}"


##################################################################
# Setup Emacs:
# rm -rfv ${SETUPDIR}/dotfiles/emacs.d
# mkdir ${SETUPDIR}/dotfiles/emacs.d

# export PRELUDE_INSTALL_DIR="${HOME}/.emacs.d/" && \
# export PRELUDE_URL="https://github.com/zafartahirov/prelude.git" && \
# curl -L https://github.com/zafartahirov/prelude/raw/master/utils/installer.sh | sh
# git clone https://github.com/hvesalai/sbt-mode.git ${HOME}/.emacs.d/.elisp/sbt-mode
export PRELUDE_INSTALL_DIR="${SETUPDIR}/dotfiles/emacs.d" && \
curl -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh    # Get the latest prelude

# Get my own configuration for the prelude
pushd .
rm -rfv ${PRELUDE_INSTALL_DIR}/personal
mkdir ${PRELUDE_INSTALL_DIR}/personal
cd ${PRELUDE_INSTALL_DIR}/personal
git init
git remote add origin https://github.com/zafartahirov/prelude.git
git pull origin master

popd

ln -sfv ${SETUPDIR}/dotfiles/emacs.d            ${HOME}/.emacs.d

##################################################################
# Setup NANO:
rm -v ${HOME}/.nanorc
# Install NANO colors:
echo -e "${INFO} Setting up NANO"
cd ${SETUPDIR}
if [ ! -d nanorc ]; then
    git clone https://github.com/nanorc/nanorc.git
fi
cd nanorc
make install
echo 'include ~/.nano/syntax/ALL.nanorc' > ~/.nanorc
# rm -rf ${SETUPDIR}/nanorc


##################################################################
# Setup scripts:
echo -e "${INFO} Setting up scripts"
if [ ! -d ${HOME}/bin ]; then
    echo -e "${WARN} ${HOME}/bin not found"
    echo "Creating directory: ${HOME}/bin/"
    mkdir ${HOME}/bin
fi

##################################################################
# Setup COLORGCC:
echo -e "${INFO} Setting up COLORGCC"
echo -e "${WARN} Please, check ${HOME}/.colorgccrc"
echo -e "${WARN} if the paths to compilers are set!"
ln -svf ${SETUPDIR}/dotfiles/colorgccrc ${HOME}/.colorgccrc
ln -svf ${SETUPDIR}/scripts/colorgcc ${HOME}/bin/colorgcc
ln -svf ${HOME}/bin/colorgcc ${HOME}/bin/color-g++
ln -svf ${HOME}/bin/colorgcc ${HOME}/bin/color-gcc
ln -svf ${HOME}/bin/colorgcc ${HOME}/bin/color-c++
ln -svf ${HOME}/bin/colorgcc ${HOME}/bin/color-cc


ln -svf ${SETUPDIR}/scripts/gpp         ${HOME}/bin/gpp         # GPP tool (C++)
ln -svf ${SETUPDIR}/scripts/githubInit  ${HOME}/bin/githubInit  # GitHub initializer
ln -svf ${SETUPDIR}/scripts/repo        ${HOME}/bin/repo        # Android GIT wrapper
ln -svf ${SETUPDIR}/scripts/fixGitPermissions   ${HOME}/bin/fixGitPermissions

if [ "$(uname)" == "Darwin" ] && hash wmctrl; then
    ln -svf ${SETUPDIR}/scripts/wmfix	${HOME}/bin/wmfix
else
    echo -e "${WARN} WMCTRL not installed. 'wmfix' is not symlinked!"
fi

##################################################################
# Emacs pacakges
pushd .
# cd ${SETUPDIR}/dotfiles/emacs.d/.elisp/
# (Need to setup MELPA :( )
# rm -rfv go-mode.el && git clone https://github.com/zafartahirov/go-mode.el.git
# rm -rfv markdown-mode && git clone git://jblevins.org/git/markdown-mode.git
popd
