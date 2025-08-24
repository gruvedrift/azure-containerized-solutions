#!/bin/bash

# Exit on error
set -e

echo 'Deleting Azure resources...'
cd ./terraform
terraform destroy -auto-approve;