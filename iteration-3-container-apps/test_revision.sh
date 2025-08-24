#!/bin/bash

# Navigate to terraform output state
cd ./terraform

CONTAINER_APP_URL=$(terraform output -raw container_app_url)

# Do 20 requests and grep version, sort them by frequency and show the number of occurrences.
for i in {1..20}; do
  curl -s "$CONTAINER_APP_URL" | grep -o 'Version [0-9.]*'
done | sort | uniq -c