#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
  echo "Error: no environment specified."
  echo "Usage: ./deploy.sh <environment>"
  exit 1
fi

echo "Starting deployment to $ENV..."

if [ "$ENV" == "production" ]; then
  echo "Production deployment requires manual approval."
  echo "Have you approved this release? (y/n)"
  read APPROVAL
  if [ "$APPROVAL" != "y" ]; then
    echo "Deployment cancelled."
    exit 1
  fi
fi

echo "Deploying application to $ENV environment..."
sleep 2
echo "Deployment to $ENV completed successfully."
exit 0
