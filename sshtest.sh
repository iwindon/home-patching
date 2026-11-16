for host in panther homebridge pihole web01 splunk nagios toolkit turtle; do
    printf "%-12s : " "$host"
    ssh \
        -i /root/.ssh/ansible_home \
        -o BatchMode=yes \
        -o ConnectTimeout=5 \
        ansible@"$host" \
        'hostname' 2>/dev/null || echo "FAILED"
done
