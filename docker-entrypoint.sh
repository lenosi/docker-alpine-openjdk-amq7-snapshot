#!/bin/sh
set -e

WORKDIR=$(pwd)

EFFECTIVE_AMQ7_USER=${AMQ7_USER:-admin}
EFFECTIVE_AMQ7_PASSWORD=${AMQ7_PASSWORD:-topsecret007}
EFFECTIVE_AMQ7_ROLE=${AMQ7_ROLE:-amq}
EFFECTIVE_AMQ7_CLUSTER_USER=${AMQ7_ROLE:-amq7Cluster}
EFFECTIVE_AMQ7_CLUSTER_PASSWORD=${AMQ7_ROLE:-topsecret007-cluster}

if [ ! "$(ls -A /var/lib/amq7/etc)" ]; then
	# Create broker instance
	cd /var/lib && \
	  /opt/A-MQ7/bin/artemis create amq7 \
		--home /opt/A-MQ7 \
		--user $EFFECTIVE_AMQ7_USER \
		--password $EFFECTIVE_AMQ7_PASSWORD \
		--role $EFFECTIVE_AMQ7_ROLE \
		--require-login \
		--cluster-user $EFFECTIVE_AMQ7_CLUSTER_USER \
		--cluster-password $EFFECTIVE_AMQ7_CLUSTER_PASSWORD

	# Get managment accesible from the outside
  sed -ie 's/localhost:8161/0.0.0.0:8161/g' amq7/etc/bootstrap.xml

	chown -R amq7:amq7 /var/lib/amq7

	cd $WORKDIR
fi

# Log to tty to enable docker logs container-name
sed -i "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -i "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -i "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

if [ "$1" = 'amq7-server' ]; then
	exec su-exec amq7 "./artemis" "run"
fi

exec "$@"
