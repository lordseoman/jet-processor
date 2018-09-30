#!/bin/bash

source /home/jet/cfg/defaults
source /home/jet/cfg/build-args
source /home/jet/cfg/$CLIENT

if [ -e /var/run/supervisord.pid ]; then
    echo "Unsafe shutdown..."
fi

if [ ! -e /home/jet/.jet.cf ]; then
    echo "Setting up Jet instance for the first time."
    cd /home/jet
    sudo -u jet /home/jet/bin/setup-jet.sh
fi

service supervisor start
exit 0
