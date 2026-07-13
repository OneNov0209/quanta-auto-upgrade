#!/usr/bin/env bash

set -e

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

if [ ! -f quanta-auto-upgrade.sh ]; then
    echo "quanta-auto-upgrade.sh not found."
    exit 1
fi

echo
read -rsp "Enter your validator wallet password: " PASSWORD
echo
echo

echo "[1/5] Installing upgrade script..."
cp quanta-auto-upgrade.sh /root/quanta-auto-upgrade.sh

sed -i "s|^PASSWORD=.*|PASSWORD=\"$PASSWORD\"|" /root/quanta-auto-upgrade.sh

chmod +x /root/quanta-auto-upgrade.sh

echo "[2/5] Installing systemd service..."
cp quanta-auto-upgrade.service /etc/systemd/system/

echo "[3/5] Installing systemd timer..."
cp quanta-auto-upgrade.timer /etc/systemd/system/

echo "[4/5] Reloading systemd..."
systemctl daemon-reload

echo "[5/5] Enabling timer..."
systemctl enable --now quanta-auto-upgrade.timer

echo
echo "=========================================="
echo "Installation completed successfully!"
echo "=========================================="
echo
echo "Run upgrade manually:"
echo "systemctl start quanta-auto-upgrade.service"
echo
echo "View logs:"
echo "journalctl -u quanta-auto-upgrade.service -f"
echo
echo "Check timer:"
echo "systemctl list-timers"
