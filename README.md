# Quanta Auto Upgrade

Automatically upgrades your Quanta validator Docker container whenever a new image is published.

## Features

- Automatically checks Docker Hub every 30 minutes
- Downloads the latest image
- Recreates the validator container
- Performs health checks after upgrade
- Automatically rolls back if the new version fails
- Runs as a systemd timer

## Requirements

- Ubuntu 22.04+
- Docker installed
- Running Quanta validator

## Installation

```bash
git clone https://github.com/OneNov0209/quanta-auto-upgrade.git
cd quanta-auto-upgrade
chmod +x install.sh
sudo ./install.sh
```

## Logs

```bash
journalctl -u quanta-auto-upgrade.service -f
```

## Manual Run

```bash
systemctl start quanta-auto-upgrade.service
```

## Timer Status

```bash
systemctl list-timers
```

## Disable

```bash
systemctl disable --now quanta-auto-upgrade.timer
```
