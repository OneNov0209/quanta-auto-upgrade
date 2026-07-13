#!/usr/bin/env bash

set -e

echo "=========================================="
echo "      Quanta Auto Upgrade Installer"
echo "=========================================="
echo

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this installer as root."
    exit 1
fi

# Pastikan Docker sudah terpasang
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed."
    exit 1
fi

# Pastikan script tersedia
if [ ! -f quanta-auto-upgrade.sh ]; then
    echo "quanta-auto-upgrade.sh not found."
    exit 1
fi

echo "[1/5] Installing upgrade script..."
cp quanta-auto-upgrade.sh /root/quanta-auto-upgrade.sh
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
echo "Useful commands:"
echo
echo "Run upgrade now:"
echo "  systemctl start quanta-auto-upgrade.service"
echo
echo "View logs:"
echo "  journalctl -u quanta-auto-upgrade.service -f"
echo
echo "Check timer:"
echo "  systemctl list-timers"
