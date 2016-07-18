#!/bin/sh -e

export ZK_ENSEMBLE_SIZE=${ZK_ENSEMBLE_SIZE:-3}
export ZK_TICK_TIME=${ZK_TICK_TIME:-2000}
export ZK_INIT_LIMIT=${ZK_INIT_LIMIT:-10}
export ZK_SYNC_LIMIT=${ZK_SYNC_LIMIT:-5}
export ZK_MAX_CLIENT_CXNS=${ZK_MAX_CLIENT_CXNS:-60}
export ENSEMBLE_SCALE_TIMEOUT=${ENSEMBLE_SCALE_TIMEOUT:-300}
export ZK_IFACE=${ZK_IFACE:-eth0}

# Wait for all zookeeper nodes to be scheduled
export SERF_JOINTO
/wait-for-ensemble.sh

# Start zookeeper
exec /opt/zookeeper/bin/zkServer.sh start-foreground
