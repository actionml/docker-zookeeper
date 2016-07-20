FROM java:8-jre-alpine

ENV ZK_VERSION 3.4.8
ENV ZK_IFACE eth0
LABEL vendor=ActionML \
      version_tags="[\"3.4\",\"3.4.8\"]"

# Update alpine and install required tools
RUN apk update && apk add --update bash curl

RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 -o /usr/local/bin/confd && \
    chmod +x /usr/local/bin/confd && \
    curl -L https://releases.hashicorp.com/serf/0.7.0/serf_0.7.0_linux_amd64.zip -o serf.zip && \
    unzip serf.zip -d /usr/local/bin && chmod +x /usr/local/bin/serf && \
    mkdir -p /opt && \
    curl -L http://www-us.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz | tar xzf - -C /opt && \
    mv /opt/zookeeper-${ZK_VERSION} /opt/zookeeper
  
VOLUME ["/data"]

ADD ./conf.d /etc/confd/conf.d
ADD ./templates /etc/confd/templates

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
