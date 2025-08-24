#!/bin/bash

set -e

# Navigate to terraform directory to read output from state file.
cd ./terraform
CONTAINER_APP_URL=$(terraform output -raw container_app_url)

hey -n 200 -c 50 "$CONTAINER_APP_URL/load"
