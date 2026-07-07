#!/bin/bash

# ---- Config ----
ENV_FILE="environments/docker-compose.prod.yml"
PROJECT="prod"
HEALTH_URL="http://localhost:8080/health"
MAX_RETRIES=5

echo "=== Saving current version as backup ==="
# Record the currently running image so we can revert to it
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' release-app-prod 2>/dev/null)
echo "Current version: ${CURRENT_IMAGE:-none (first deploy)}"

echo "=== Deploying new version ==="
docker compose -p $PROJECT -f $ENV_FILE up -d --build

echo "=== Running health check ==="
HEALTHY=false
for i in $(seq 1 $MAX_RETRIES); do
  echo "Health check attempt $i of $MAX_RETRIES..."
  sleep 5
  if curl -sf $HEALTH_URL > /dev/null; then
    HEALTHY=true
    echo "Health check PASSED"
    break
  fi
  echo "Not healthy yet..."
done

# ---- Decision ----
if [ "$HEALTHY" = true ]; then
  echo "=== DEPLOYMENT SUCCEEDED — new version is live ==="
  exit 0
else
  echo "=== DEPLOYMENT FAILED — health check never passed ==="
  if [ -n "$CURRENT_IMAGE" ]; then
    echo "=== ROLLING BACK to $CURRENT_IMAGE ==="
    docker compose -p $PROJECT -f $ENV_FILE down
    docker run -d -p 8080:3000 --name release-app-prod "$CURRENT_IMAGE"
    echo "=== ROLLBACK COMPLETE — previous version restored ==="
  else
    echo "No previous version to roll back to (this was the first deploy)."
    docker compose -p $PROJECT -f $ENV_FILE down
  fi
  exit 1
fi
