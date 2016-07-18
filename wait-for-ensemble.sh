#!/bin/sh -e

# Serf agent startup string
SERF_AGENT="serf agent -tag role=zookeeper -event-handler=query:ipaddr=/ipaddr.sh"
# Set join address (in case the second and the following agents are started)
if [ ! -z "${SERF_JOINTO}" ]; then
  SERF_AGENT="${SERF_AGENT} -join=${SERF_JOINTO}"
fi


## Exit if current time hit the timeout
timeout_on() {
  end_seconds=$1
  if [ $(date +'%s') -ge $end_seconds ]; then
    >&2 echo "Timed out!"
    exit 1
  fi
}


## Check ensemble members number
ensemble_scale_complete() {
  acks=$(serf query dummy | grep "Total Acks" | sed 's/.*: //')
  [ $acks -eq $ZK_ENSEMBLE_SIZE ] || return $?
}


## ------------------------------------------------------------------

## 1. Start serf in the background
${SERF_AGENT} &

# Set to time out at `now + timeout`
echo -e "Waiting for all members of ensemble to scale up, can take up to ${ENSEMBLE_SCALE_TIMEOUT} seconds...\n"
end_time=$(date +'%s')
end_time=$((end_time+ENSEMBLE_SCALE_TIMEOUT))

## 2. Wait for all ensemble members to appear
while : ; do
  sleep 5
  ensemble_scale_complete && break || continue
  timeout_on $end_time
done

## 3. Get a space separated of list of ensemble member ip addresses
members=$(serf query ipaddr $ZK_IFACE | grep 'Response from' | sed -r 's/.*: //' | sort)
ZK_ENSEMBLE_HOSTS=$(echo $members | sed 's/ /,/g')
echo -e "==> Zookeeper quorum:\n    $ZK_ENSEMBLE_HOSTS"

## Couldn't increment index in golang template, so this is a workaround to count from index 1
export ZK_ENSEMBLE_HOSTS=",${ZK_ENSEMBLE_HOSTS}"

## 4. Calculate myid
myid=0
for addr in $members; do
  myid=$((myid+1))
  ip a | grep -q $addr && break || :
done
export ZK_MYID=$myid

## 5. Give time for serf queries to propogate on other nodes and generate static configuration
sleep 10
killall -TERM serf
confd -onetime -backend env
