#!/bin/bash
#############################################################
#
# This is a modified version to work with Infosats migration
#
#############################################################

echo "Doing first time setup..\n"

source cfg/defaults
source cfg/build-args
if [ -e cfg/$CLIENT ]; then
    source cfg/$CLIENT
fi

if [ ! -d Jet ]; then
    echo -n "Enter your Fullname: "
    read FULLNAME
    echo -n "Enter your Bazaar username: "
    read USERNAME
    echo -n "Enter your email address: "
    read EMAIL

    bzr whoami "${FULLNAME} <${EMAIL}>"

    cd
    cd .bazaar/plugins/
    bzr branch bzr+ssh://${USERNAME}@svn.obsidian.com.au/home/bzr/.plugins/obsidian/
    cd

    bzr obs-branch --repo=bugfix futuredev futuredev-bugfix
    cd futuredev-bugfix
    bzr obs-login $USERNAME
    cd 
    bzr obs-branch --repo=${BRANCH} ${CLIENT} ${CLIENT}-${BRANCH}
    cd ${CLIENT}-${BRANCH}
    bzr obs-login $USERNAME
    cd

    ln -sv futuredev-bugfix Jet
    cd Jet/etc
    ln -s ../local/etc/licence.key .
    ln -s ../../${CLIENT}-${BRANCH}/local/etc/local.cfg .
    cd 

    if [ -e /opt/Reports ]; then
        cd Jet/local/var/
        ln -s /opt/Reports reports_repo
        cd
    fi

    cd Jet
    echo "Applying ZeroMQ patch.."
    patch -p0 -i ../futuredev-imports-zeromq.patch 
    cd

    cd Jet/modules/reportfe
    python setup.py egg_info
    cd

    cd Jet/modules/pylonfe
    python setup.py egg_info
    cd
fi

chown jet:jet -R Jet

if [ ! -e Jet/var/log/supervisor ]; then
    mkdir Jet/var/log/supervisor
fi
touch Jet/var/log/supervisor/pylons.log
touch Jet/var/log/supervisor/pylons.err
touch Jet/var/log/supervisor/radius.log
touch Jet/var/log/supervisor/radius.err
touch Jet/var/log/supervisor/reportfe.log
touch Jet/var/log/supervisor/reportfe.err
touch Jet/var/log/supervisor/supervisord.log

echo -e "BRANCH='futuredev-bugfix ${CLIENT}-${BRANCH}'\nMAIN='futuredev-bugfix'" > .jet.cfg

