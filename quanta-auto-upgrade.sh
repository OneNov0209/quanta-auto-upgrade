#!/usr/bin/env bash

set -euo pipefail

IMAGE="xd637/quanta-node:latest"
CONTAINER="quanta-validator"
DATA="/opt/quanta_data_v2"
PASSWORD=""
BOOTSTRAP="34.87.128.33:8333"

rollback() {
    echo
    echo "[ROLLBACK] Restoring previous container..."

    docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

    docker run -d \
      --name "$CONTAINER" \
      --restart always \
      --network host \
      -v "$DATA":/home/quanta/quanta_data \
      -e QUANTA_WALLET_PASSWORD="$PASSWORD" \
      "$OLD_IMAGE" \
      quanta start \
      --validator-wallet /home/quanta/quanta_data/validator.qua \
      --bootstrap "$BOOTSTRAP" >/dev/null

    echo "[ROLLBACK] Previous version restored."
    exit 1
}

echo "=================================================="
echo "Quanta Auto Upgrade - $(date)"
echo "=================================================="

if [[ -z "$PASSWORD" ]]; then
    echo "ERROR: Wallet password has not been configured."
    echo "Please reinstall using install.sh"
    exit 1
fi

if ! docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "ERROR: Container '$CONTAINER' not found."
    exit 1
fi

OLD_IMAGE=$(docker inspect "$CONTAINER" --format '{{.Image}}')

OLD_DIGEST=$(docker image inspect "$IMAGE" \
--format '{{index .RepoDigests 0}}' 2>/dev/null || true)

echo "[1/6] Pull latest image..."
timeout 300 docker pull "$IMAGE" >/dev/null

NEW_DIGEST=$(docker image inspect "$IMAGE" \
--format '{{index .RepoDigests 0}}')

echo
echo "Old Digest : ${OLD_DIGEST:-none}"
echo "New Digest : $NEW_DIGEST"
echo

if [[ "$OLD_DIGEST" == "$NEW_DIGEST" ]]; then
    echo "Already latest."
    exit 0
fi

echo "[2/6] Recreating container..."

docker stop "$CONTAINER" >/dev/null 2>&1 || true
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true

docker run -d \
  --name "$CONTAINER" \
  --restart always \
  --network host \
  -v "$DATA":/home/quanta/quanta_data \
  -e QUANTA_WALLET_PASSWORD="$PASSWORD" \
  "$IMAGE" \
  quanta start \
  --validator-wallet /home/quanta/quanta_data/validator.qua \
  --bootstrap "$BOOTSTRAP" >/dev/null

echo "[3/6] Waiting for node..."
sleep 30

RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null || echo false)
RESTARTING=$(docker inspect -f '{{.State.Restarting}}' "$CONTAINER" 2>/dev/null || echo false)

if [[ "$RUNNING" != "true" || "$RESTARTING" == "true" ]]; then
    echo "Container failed to start."
    rollback
fi

echo "[4/6] Checking node status..."

STATUS=$(timeout 20 docker exec "$CONTAINER" quanta status 2>/dev/null || true)

if ! echo "$STATUS" | grep -q "RUNNING"; then
    echo "Node is not healthy."
    rollback
fi

echo "[5/6] Upgrade successful."
echo
echo "$STATUS"
echo

echo "[6/6] Done."
