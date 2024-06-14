#!/bin/bash

INFLUX_HOST="http://localhost:8086"
INFLUX_TOKEN="yCae0n1eDx-iNL1EKotdwdEc6FrwpGLLizsdiiPH1far6JsZV3-F1XY1ShLqXSM8mRfEznEtvj-GDePK4K9Cpg=="
ORG_ID="d253e3a877fd8016"
REMOTE_API_TOKEN="48aFRIN-B-rdOZW3ZVPiWjT2oZS-UXvwH-NZ8Ma6Er9DuTFNANyCoBUMUhe8-YDQnULNgPlm6-y21-lGNmnIRQ=="
REMOTE_ORG_ID="ed5b33935ded1b10"
REMOTE_URL="https://us-east-1-1.aws.cloud2.influxdata.com"
LOCAL_BUCKET_ID="c43d8abca622a6c5"
REMOTE_BUCKET_NAME="sensores_cloud"

# Wait for InfluxDB to start up
until curl -s -o /dev/null -w "%{http_code}" "$INFLUX_HOST/api/v2/setup" | grep -q "204\|200"; do
  echo "Waiting for InfluxDB to start..."
  sleep 5
done

# Create the remote connection
curl --request POST "$INFLUX_HOST/api/v2/remotes" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "allowInsecureTLS": false,
    "description": "Conexion a InfluxDB Cloud",
    "name": "Remote Connection to Cloud",
    "orgID": "'"$ORG_ID"'",
    "remoteAPIToken": "'"$REMOTE_API_TOKEN"'",
    "remoteOrgID": "'"$REMOTE_ORG_ID"'",
    "remoteURL": "'"$REMOTE_URL"'"
  }'

# Get the remote ID
REMOTE_ID=$(curl --request GET "$INFLUX_HOST/api/v2/remotes" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: application/json" | jq -r '.remotes[] | select(.name=="Remote Connection to Cloud") | .id')

# Create the replication stream
curl --request POST "$INFLUX_HOST/api/v2/replications" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "dropNonRetryableData": false,
    "localBucketID": "'"$LOCAL_BUCKET_ID"'",
    "maxAgeSeconds": 604800,
    "maxQueueSizeBytes": 67108860,
    "name": "Replication Stream to Cloud",
    "orgID": "'"$ORG_ID"'",
    "remoteBucketName": "'"$REMOTE_BUCKET_NAME"'",
    "remoteID": "'"$REMOTE_ID"'"
  }'

echo "Replication setup completed."

