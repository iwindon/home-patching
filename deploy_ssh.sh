#!/usr/bin/env bash
set -u

KEY="/root/.ssh/ansible_home.pub"

SERVERS=(
    panther
    homebridge
    pihole
    web01
    splunk
    turtle
)

echo "========================================"
echo " Ansible SSH Key Deployment"
echo "========================================"

for SERVER in "${SERVERS[@]}"; do

    echo
    echo "==> $SERVER"

    if ssh root@"$SERVER" \
        'install -d -m 700 -o ansible -g ansible /home/ansible/.ssh &&
         cat >> /home/ansible/.ssh/authorized_keys &&
         chown ansible:ansible /home/ansible/.ssh/authorized_keys &&
         chmod 600 /home/ansible/.ssh/authorized_keys &&
         restorecon -Rv /home/ansible/.ssh >/dev/null 2>&1 || true' \
        < "$KEY"
    then
        echo "    SUCCESS: Key installed on $SERVER"
    else
        echo "    FAILED: $SERVER"
    fi

done


echo
echo "==> toolkit"

if scp "$KEY" windoni@toolkit:/tmp/ansible_home.pub
then
    ssh -t windoni@toolkit '
        sudo install -d -m 700 -o ansible -g ansible /home/ansible/.ssh &&
        sudo sh -c "cat /tmp/ansible_home.pub >> /home/ansible/.ssh/authorized_keys" &&
        sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys &&
        sudo chmod 600 /home/ansible/.ssh/authorized_keys &&
        rm -f /tmp/ansible_home.pub
    '

    echo "    Toolkit key installation complete."
else
    echo "    FAILED: Could not copy key to toolkit"
fi


echo
echo "========================================"
echo " Testing Ansible SSH connectivity"
echo "========================================"

ALL_SERVERS=(
    panther
    homebridge
    pihole
    web01
    splunk
    toolkit
    turtle
)

for SERVER in "${ALL_SERVERS[@]}"; do

    printf "%-12s : " "$SERVER"

    if ssh \
        -i /root/.ssh/ansible_home \
        -o BatchMode=yes \
        -o ConnectTimeout=5 \
        ansible@"$SERVER" \
        'echo OK' 2>/dev/null
    then
        :
    else
        echo "FAILED"
    fi

done
