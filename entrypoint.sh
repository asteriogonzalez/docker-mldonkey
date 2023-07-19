#!/bin/bash

echo "-------------------------------------------------"
echo "mldonkey runs using uid=gui=1000"
echo "you can change this by setting these ENV vars"
echo "MLDONKEY_UID: ${MLDONKEY_UID}"
echo "MLDONKEY_GID: ${MLDONKEY_GID}"
echo "MLDONKEY_ALLOWED_IPS: ${MLDONKEY_ALLOWED_IPS}"
#echo ""
#echo "admin password can be set also setting ENV:"
#echo "MLDONKEY_ADMIN_PASSWORD: ${MLDONKEY_ADMIN_PASSWORD}"
echo "-------------------------------------------------"
#
# check if I need to change uid / gui
if [ ! -f /root/mldonkey_user_ok ]; then
    echo "Checking MLDONKEY_UID and MLDONKEY_GID values for 1st time."
	if [ ! -z "$MLDONKEY_UID" ]; then
    		echo "Resetting mldonkey uid to $MLDONKEY_UID"
    		usermod -u $MLDONKEY_UID mldonkey
	fi

	if [ ! -z "$MLDONKEY_GID" ]; then
    		echo "Resetting mldonkey gid to $MLDONKEY_GID"
    		groupmod -g $MLDONKEY_GID mldonkey
	fi
	touch /root/mldonkey_user_ok
fi

#
# Checking if mldonkey has been already configured
if [ ! -f /var/lib/mldonkey/downloads.ini ]; then
    echo ">> Setting permissions for /var/lib/mldonkey"
    chown mldonkey:mldonkey /var/lib/mldonkey

    echo ">> Starting mldonkey server for 1st time ..."
    su mldonkey -c 'mldonkey' &

    echo ">> Waiting for mldonkey to start..."
    sleep 1
    echo ">> Configuring mldonkey"
    if [ ! -z "$MLDONKEY_ALLOWED_IPS" ]; then
        echo ">> Allowing connecting from $MLDONKEY_ALLOWED_IPS"
        echo "/usr/lib/mldonkey/mldonkey_command  'set allowed_ips ${MLDONKEY_ALLOWED_IPS}'"

        su mldonkey -c "/usr/lib/mldonkey/mldonkey_command  'set allowed_ips ${MLDONKEY_ALLOWED_IPS}'"
        sleep 1
    fi

    # export MLDONKEY_ADMIN_PASSWORD
    # if [ -z "$MLDONKEY_ADMIN_PASSWORD" ]; then
    #     echo ">> Must set a MLDONKEY_ADMIN_PASSWORD !, killing mlnet"
    #     #su mldonkey -c '/usr/lib/mldonkey/mldonkey_command -p "" "kill"'
    #     su mldonkey -c '/usr/lib/mldonkey/mldonkey_command "kill"'
    # else
    #     #su mldonkey -c '/usr/lib/mldonkey/mldonkey_command -p "" "useradd admin $MLDONKEY_ADMIN_PASSWORD"'
    #     su mldonkey -c '/usr/lib/mldonkey/mldonkey_command "useradd admin $MLDONKEY_ADMIN_PASSWORD"'
    #     su mldonkey -c '/usr/lib/mldonkey/mldonkey_command -u admin -p "$MLDONKEY_ADMIN_PASSWORD" "kill"'
    # fi


    if [ ! -z "$MLDONKEY_SERVER_MET" ]; then
        for link in $MLDONKEY_SERVER_MET
            do
                echo "  + server.met: $link"
                echo "/usr/lib/mldonkey/mldonkey_command urladd server.met $link"
                su mldonkey -c "/usr/lib/mldonkey/mldonkey_command urladd server.met $link"
            done
        sleep 1
        echo ">> connecting to more servers..."
        su mldonkey -c '/usr/lib/mldonkey/mldonkey_command  c'
    fi
    if [ ! -z "$MLDONKEY_SERVERS" ]; then
        for link in $MLDONKEY_SERVERS
            do
                echo "  + adding $link"
                echo "/usr/lib/mldonkey/mldonkey_command '$link'"
                su mldonkey -c "/usr/lib/mldonkey/mldonkey_command '$link'"
            done
        sleep 1
        echo ">> connecting to more servers..."
        su mldonkey -c '/usr/lib/mldonkey/mldonkey_command  c'
    fi

    echo ">> Saving configuration"
    su mldonkey -c '/usr/lib/mldonkey/mldonkey_command  save'
    echo ">> Kill mldonkey server, so it will be restarted as normal"
    su mldonkey -c '/usr/lib/mldonkey/mldonkey_command  kill'
fi

echo ">> Resuming mldonkey server"
su mldonkey -c 'mldonkey'
