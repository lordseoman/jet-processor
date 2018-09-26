#!/bin/bash

if [ -e /var/run/supervisord.pid]; then
    echo "Unsafe shutdown..."
fi

/usr/bin/supervisord

