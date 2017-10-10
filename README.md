## Managing Kafka clusters in Kubernetes

### Installing

The installation is done using helm chart:

```bash
helm install kafka-cluster
``` 

### Helm Chart Parameters

```yaml
# imageRegistry is the address of the container image registry to use
# imageRegistry: index.docker.io

# pullPolicy is the kubernetes policy to use for pulling images: Always, IfNotPresent, Never
pullPolicy: IfNotPresent
# applicationName is the default name of the application
applicationName: kafka-cluster

kafka:
  # kafka.image is the name of kafka container image to use
  image: nbogojevic/kafka
  # kafka.tag is the tag of kafka container image to use
  tag: latest
  # kafka.serviceName is the service name used by clients to find the cluster
  serviceName: kafka
  # kafka.dnsName is the name used by StatefulSet to identify instances
  dnsName: broker
  # kafka.nodes is set to number of nodes in kafka cluster
  nodes: 3
  # kafka.jvmFlags are default java options to use with kafka
  jvmFlags: -Xmx1G
  # kafka.storageSize is the default size of storage when using persistent volumes
  storageSize: 2GiB
  # kafka.persistent is set to true to use persitent volumes
  persistent: false
  # kafka.nodeSelector can be set with node labels to use when choosing nodes to deploy
  nodeSelector:

zookeeper:
  # zookeeper.image is the name of zookeeper container image to use
  image: nbogojevic/zookeeper
  # zookeeper.tag is the tag of zookeeper container image to use
  tag: latest
  # zookeeper.serviceName is the service name used by clients to find the cluster
  serviceName: zookeeper
  # zookeeper.dnsName is the name used by StatefulSet to identify instances
  dnsName: zoo
  # zookeeper.nodes is set to number of nodes in zookeeper cluster
  nodes: 3 
  # zookeeper.jvmFlags are default java options to use with kafka
  jvmFlags: -Xmx512m
  # zookeeper.nodeSelector can be set with node labels to use when choosing nodes to deploy
  nodeSelector:     # Node labels can be specified unde this key

# hawkular is set to true to enable hawkular metrics
hawkular: false   

# prometheus is set to true to enable prometheus metrics
prometheus: false


# jolokia is set to true if jolokia JMX endpoint should be exposed
jolokia: true

# jolokiaUsername is set to the name of jolokia user for basic authentication
#jolokiaUsername: jolokia

# jolokiaPassword can be set to the password to use. If not specified, a random password is generated
#jolokiaPassword: jolokia
```

## Kafka

### Kafka as Kubernetes StatefulSet

Kafka is run as a Kubernetes StatefulSet (or PetSet in older versions). 

#### Storage
Kafka can be run with or without persitent volumes.


When running with persitent volumes, the data is saved on instance or node crash. When running without persitent volumes, the data is stored locally on the node a kubernetes node loss may result in data loss, so high-availability and resiliency should be supported by kafka mechanisms, e.g. setting replication factor sufficiently high.

As for best performances, one might perfer specific local storage characteristics (SSD), helm chart allows usage of node selector to select instances where kafka would be deployed.  

### Kafka container image

Default kafka container image is based on fabric8/s2i-java image. The docker build is located in `docker-kafka/`.

#### Customizing Kafka

It is possible to customize kafka container to advertise different host and port. This is done by specifying following
two environmnet variables: `KAFKA_ADVERTISED_HOST` and `KAFKA_ADVERTISED_PORT`. When they are specified, the kafka
containers will use those values to advertise their address instead of default ones. 


### Kafka in OpenShift

For details see [openshift/README.md](openshift/README.md)

## Zookeeper

Zookeeper also runs as a Stateful Set.

Zookeeper uses local storage, so if you lose your zookeeper cluster, kafka will be unaware that persisted topics exist.
The data is still there, but you will need to re-create topics. This can be done using `kafka-operator`.

### Zookeeper container image

Default zookeeper container image is based on fabric8/s2i-java image. The docker build is located in `docker-zookeeper/`.

