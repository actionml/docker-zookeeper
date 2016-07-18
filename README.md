[![DockerHub](https://img.shields.io/badge/docker-available-blue.svg)](https://hub.docker.com/r/dennybaa/zookeeper) [![Build Status](https://travis-ci.org/dennybaa/docker-zookeeper.svg?branch=master)](https://travis-ci.org/dennybaa/docker-zookeeper)
# Docker zookeeper container (standalone)

This container might be used to bring up Zookeeper standalone cluster. Container has complicated configuration generation using confd and serf. Serf is used to solve zookeeper's lack of dynamic configuration (as of **3.4.8** version), this means that ensemble members should be known before start up which causes chicken-egg problem for a docker environment.

## Start up scenario

1. Serf cluster is brought up, containers wait when all members of ensemble appear to scale up (go online).
1. Once the required number of members appeared and they ip configuration determined configs generation takes place.
1. Zookeeper service is brought up on line.

## Configuration (environment variables)

|Variable|Description|Default|
|-|
|**SERF_JOINTO**|Specifies the host address when starting the second and the following zookeeper instances.||
|ENSEMBLE_SCALE_TIMEOUT|Ensemble scale up timeout. Specifies deadline for all ensemble members to go online.|`300` sec|
|ZK_ENSEMBLE_SIZE|Required number of Zookeeper instances which form quorum.|`3`|
|ZK_IFACE|Specifies interface of a container where Zookeeper's address will be fetched from.|`eth0`|
|ZK_TICK_TIME|Sets *tickTime*.|`2000` ms|
|ZK_INIT_LIMIT|Sets *initLimit*.|`10` ticks|
|ZK_SYNC_LIMIT|Sets *syncLimit*.|`5` ticks|
|ZK_MAX_CLIENT_CXNS|Sets *maxClientCnxns*.|`60`|

# Cluster startup example

```
# Start containers interactively (from different consoles).
docker run -it --rm --name zookeeper-a dennybaa/zookeeper

# Grab ip address of an instance to join to (Serf join).
# Start 2nd and 3d zookeeper instances
zk_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' zookeeper-a)
docker run -it --rm -e SERF_JOINTO=$zk_ip dennybaa/zookeeper

zk_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' zookeeper-a)
docker run -it --rm -e SERF_JOINTO=$zk_ip dennybaa/zookeeper
```

As soon as the ensemble converges the quorum will be printed out bellow `==> Zookeeper quorum:`, it can be pasted somewhere into another configuration (for example HBase).

# Authors

 - Denis Baryshev (<dennybaa@gmail.com>)
