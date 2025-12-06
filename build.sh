#!/bin/bash

# Build Lambda layer
./backend/layer/build_layer_dock.sh

# start terraform build
terraform -chdir=infra init 
terraform -chdir=infra apply -auto-approve

# init db with tables
uv run ops/db_create_tables.py

# Populate db with data from latest month
aws lambda invoke \
    --function-name eia_api_to_postgres \
    --cli-binary-format raw-in-base64-out \
    --payload '{"key": "value"}' \
    response.json

# Set env var name for api gateway
export API_GATEWAY_ID=$(aws apigateway get-rest-apis --output json | jq -r '.["items"][0].["id"]')
export API_GATEWAY_URL=$"https://$API_GATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/data?groupby=all"

set API_GATEWAY_ID $(aws apigateway get-rest-apis --output json | jq -r '.["items"][0].["id"]')
set API_GATEWAY_URL "https://$API_GATEWAY_ID.execute-api.us-west-2.amazonaws.com/dev/data?groupby=all"

sed -i '' "s|API_GATEWAY_URL=.*|API_GATEWAY_URL=$API_GATEWAY_URL|" backend/api_proxy/.env
# Build docker image
docker build -t react-app .

# Start Docker Container
docker run -d \
  -p 8080:5000 \
  --env-file backend/api_proxy/.env \
  react-app

