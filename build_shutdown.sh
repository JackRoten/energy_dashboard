#!/bin/bash

# Stop Docker container
docker stop $(docker ps -q)

# Destroy cloud services
terraform -chdir=infra destroy -auto-approve
