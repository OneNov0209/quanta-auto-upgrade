# Quanta Auto Upgrade

Automatically upgrades your Quanta validator Docker container whenever a new image is published.

## Features

- Automatically checks Docker Hub every 30 minutes
- Downloads the latest Docker image
- Recreates the validator container
- Performs a health check after upgrade
- Automatically rolls back if the new version fails
- Runs as a systemd timer
- Simple one-command installation

## Requirements

- Ubuntu 22.04+
- Docker installed
- Running Quanta validator

## Installation

Run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OneNov0209/quanta-auto-upgrade/main/install.sh)
```

The installer will:

- Download all required files
- Ask for your validator wallet password
- Install the systemd service
- Enable the auto-upgrade timer

## Run Upgrade Now

```bash
systemctl start quanta-auto-upgrade.service
```

## View Logs

```bash
journalctl -u quanta-auto-upgrade.service -f
```

## Check Timer

```bash
systemctl status quanta-auto-upgrade.timer
```

## Disable

```bash
systemctl disable --now quanta-auto-upgrade.timer
```

## License

MIT License
