#!/usr/bin/env bash

set -e

REPO="https://raw.githubusercontent.com/OneNov0209/quanta-auto-upgrade/main"

echo "=========================================="
echo "      Quanta Auto Upgrade Installer"
echo "=========================================="
echo

if [ "$EUID" -ne 0 ]; then
    echo "Please run this installer as root."
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed."
    exit 1
fi

echo
read -rsp "Enter your Quanta wallet password: " PASSWORD
echo
echo

echo "[1/6] Downloading upgrade script..."
curl -fsSL "$REPO/quanta-auto-upgrade.sh" -o /root/quanta-auto-upgrade.sh

echo "[2/6] Configuring password..."
sed -i "s|^PASSWORD=.*|PASSWORD=\"$PASSWORD\"|" /root/quanta-auto-upgrade.sh
chmod +x /root/quanta-auto-upgrade.sh

echo "[3/6] Downloading systemd service..."
curl -fsSL "$REPO/quanta-auto-upgrade.service" \
-o /etc/systemd/system/quanta-auto-upgrade.service

echo "[4/6] Downloading systemd timer..."
curl -fsSL "$REPO/quanta-auto-upgrade.timer" \
-o /etc/systemd/system/quanta-auto-upgrade.timer

echo "[5/6] Reloading systemd..."
systemctl daemon-reload

echo "[6/6] Enabling timer..."
systemctl enable --now quanta-auto-upgrade.timer

echo
echo "=========================================="
echo "Installation completed successfully!"
echo "=========================================="
echo
echo "Run now:"
echo "systemctl start quanta-auto-upgrade.service"
echo
echo "Logs:"
echo "journalctl -u quanta-auto-upgrade.service -f"
echo
echo "Timer:"
echo "systemctl status quanta-auto-upgrade.timer"
