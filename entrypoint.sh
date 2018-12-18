#!/bin/bash

# Read environment variables from file and export them.
file_env() {
    while read -r line || [[ -n $line ]]; do
        export $line
    done < "$1"
}

source /home/jet/cfg/defaults
source /home/jet/cfg/build-args
if [ -e /home/jet/cfg/$CLIENT ]; then
    source /home/jet/cfg/$CLIENT
fi

JETDB_IP=`dig +short -t SRV db.local | awk '{ print $4 }'`
FILETRACKER_IP=`dig +short -t SRV filetracker.local | awk '{ print $4 }'`
export $JETDB_IP $FILETRACKER_IP

if [ -f /root/environment_vars ]; then
    file_env /root/environment_vars
fi

if [ -e /var/run/supervisord.pid ]; then
    echo "Unsafe shutdown..."
fi

if [ ! -e /home/jet/.jet.cf ]; then
    echo "Setting up Jet instance for the first time."
    cd /home/jet
    sudo -u jet /home/jet/bin/setup-jet.sh
fi

if [ -e /opt/ramdisk ]; then
    if [ ! -e /opt/ramdisk/db ]; then
        mkdir /opt/ramdisk/db
    fi
    chown -R jet:jet /opt/ramdisk/db
fi

echo "Running dynamic update."
chmod 755 /opt/patches/runContainer.sh
/opt/patches/runContainer.sh

echo "Setting up environment variables for Jet."
python /home/jet/bin/setup-env.py
chown jet:jet /home/jet/Jet/.env

echo "Running jet pre-supervisor startup script."
sudo -u jet /home/jet/bin/startup.sh

service supervisor start
supervisorctl start $1

term_handler() {
    supervisorctl stop all
    service supervisor stop
    exit 0;
}

trap 'term_handle' SIGTERM

while true; do :; done

exit 0
