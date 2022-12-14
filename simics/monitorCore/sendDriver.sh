#!/bin/bash
#
# Copy a client and a file for that client to send to a target.
# The files are copied to a driver whose ssh port is mapped to
# localhost 4022 via Simics real networks and port forwarding.
# Assumes the driver has a user "mike", and ssh keys are used
#
cleanup() {
    # kill all processes whose parent is this process
    pkill -P $$
}

for sig in INT QUIT HUP TERM; do
  trap "
    cleanup
    trap - $sig EXIT
    kill -s $sig "'"$$"' "$sig"
done
trap cleanup EXIT
fname=/tmp/sendudp
#
# Catch failures that likely can't occur in this context
#     sendDriver.sh ssh_port client_path target_ip target_port header
#
ssh_port=$1
i="0"
echo "sendDriver port $ssh_port" >/tmp/sendDriver.log
while !  scp -o "StrictHostKeyChecking=no" -P $ssh_port $fname mike@localhost:/tmp/sendudp
do
    sleep 1
    i=$[$i+1]
    if [ $i -gt 10 ];then
        exit
    fi
done
echo "sendDriver did sendudp" >>/tmp/sendDriver.log
scp -o "StrictHostKeyChecking=no" -P $ssh_port $2 mike@localhost:/tmp/
base=$(basename -- $2)
ssh -o "StrictHostKeyChecking=no" -p $ssh_port mike@localhost chmod a+x /tmp/$base
echo "now run it" >>/tmp/sendDriver.log
ssh -o "StrictHostKeyChecking=no" -p $ssh_port mike@localhost /tmp/$base $3 $4 $5
echo "back from run" >>/tmp/sendDriver.log
