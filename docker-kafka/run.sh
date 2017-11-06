#!/bin/bash

# Command line arguments given to this script
export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }"
# Use Prometheus exporter if defined
if [ ! -z "$PROMETHEUS_EXPORTER_CONF" ]; then
    if [ -f /opt/jmx_exporter/conf/jmx_exporter.yaml ]; then
        export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }${PROMETHEUS_EXPORTER_CONF}"
    fi
fi
# Add jolokia or agent bond
if [ -f /opt/agent-bond-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(agent-bond-opts)"
elif [ -f /opt/agentbond/agent-bond-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/agentbond/agent-bond-opts)"
elif [ -f /opt/jolokia/jolokia-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/jolokia/jolokia-opts)"
fi

export KAFKA_PROPERTIES_OVERRIDES="--override broker.id=$(hostname | awk -F'-' '{print $2}')"

bin/kafka-server-start.sh /opt/mounted/config/server.properties ${KAFKA_PROPERTIES_OVERRIDES}

