#!/bin/sh -e

# the search server variable was renamed after the upgrade to elasticsearch 7
export SEARCH_SERVER_ES7="$SEARCH_SERVER"

# make sure that there is an actual authentication mechanism in place, if necessary
if [ -n "$MONGODB_AUTH" ]
then
    export MONGOID_AUTH_MECH=":scram"
fi

echo "Waiting for mongodb/elasticsearch..."

WAIT_MONGODB=""

if [ -n "$MONGODB_REPLICA_SET" ]
then
  echo "MongoDB is using replicas, so there is no need to wait for it to be ready"
  export MONGOHQ_URL="$MONGODB_HOST/$MONGODB_DATABASE?replicaSet=$MONGODB_REPLICA_SET"
else
  export MONGOHQ_URL="mongodb://$MONGODB_AUTH$MONGODB_HOST:$MONGODB_PORT/$MONGODB_DATABASE"
  WAIT_MONGODB="-wait tcp://$MONGODB_HOST:$MONGODB_PORT"
fi

dockerize $WAIT_MONGODB -wait $SEARCH_SERVER -wait-retry-interval 5s -timeout 600s

exec "$@"
