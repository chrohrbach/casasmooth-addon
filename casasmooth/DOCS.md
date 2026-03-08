# casasmooth Add-on Documentation

## Overview

casasmooth is a Smart Home configuration and automation server for Home Assistant.
It generates Lovelace dashboards, entity configurations and automations from your
device registry, and manages custom components, scripts and themes.

This is the **production add-on**. The application runs from a pre-built Docker image
and is ready to use immediately after installation.

---

## Installation

1. Add this repository to your Home Assistant:  
   **Settings → Add-ons → Add-on store → ⋮ → Repositories**  
   `https://github.com/chrohrbach/casasmooth-addon`

2. Find **casasmooth** in the add-on store and click **Install**.

3. Start the add-on. On first boot it will:
   - Copy all resource files to `/config/casasmooth/`
   - Install **Mosquitto broker** and **OpenSSH** if not already present
   - Generate casasmooth YAML/configuration files under `/config/casasmooth/locals/`

4. Open the add-on web UI to access the API docs, or browse to `http://homeassistant.local:28100/docs`.

---

## Configuration

The add-on exposes the following options:

| Option | Default | Description |
|---|---|---|
| `api_port` | `28100` | Port for the casasmooth API server |
| `log_level` | `info` | Log verbosity (`debug`, `info`, `warning`, `error`) |

---

## Folder Structure

After installation the following directories are created under `/config/casasmooth/`:

| Path | Purpose |
|---|---|
| `resources/` | Lovelace custom cards (copied to `/config/www/community/resources/`) |
| `custom_components/` | HA custom integrations (copied to `/config/custom_components/`) |
| `commands/` | Shell scripts used by `shell_command:` automations |
| `lib/` | Shared bash libraries |
| `images/` | Static images (`cs_logo.png`) |
| `medias/` | Camera snapshots and media files |
| `locals/` | Generated YAML (`prod/`), staging (`last/`), backups (`back/`) |
| `cache/` | Performance caches (resource manifest, etc.) |
| `logs/` | Application logs |
| `www/` | Web assets served by Home Assistant (`/local/`) |

> **Note:** Application data (`app/data/`) and multi-language text templates are bundled
> inside the container image and are not exposed on the host filesystem.

If dependency installation fails on first boot, the add-on will retry on the next start.

---

## Ports

| Port | Protocol | Description |
|---|---|---|
| `28100` | TCP | casasmooth REST API |
| `8003` | TCP | casasmooth MCP (Model Context Protocol) server |

---

## SSH Access

The **OpenSSH** add-on is installed automatically. To enable key-based SSH access:

1. Open **Settings → Add-ons → OpenSSH → Configuration**.
2. Add your public key under `authorized_keys`.
3. Start the add-on.

---

## Updates

The add-on image is versioned. When a new image is available, HA will notify you in
the add-on store. After updating the add-on:

- Static files (resources, commands, etc.) are synchronised automatically.

---

## Uninstall

Before uninstalling the add-on, run the casasmooth cleanup command first:

```bash
python3 -m app.cli.cs_main cleanup uninstall
```

This cleanup step removes casasmooth-managed traces before the add-on is removed:

- Removes the casasmooth block from `/config/configuration.yaml`
- Resets the default dashboard if a casasmooth dashboard is active
- Clears `cs_*` labels
- Removes casasmooth runtime artifacts generated on the Home Assistant host

After that, uninstall the add-on normally from Home Assistant.

If you want a full purge of the source tree as well, delete `/config/casasmooth`
manually after uninstall.

---

## Troubleshooting

### "SUPERVISOR_TOKEN not available"
Make sure the add-on has `hassio_api: true`. This is set by default in the production
config. Re-install the add-on if the option was changed.

### "Could not install Mosquitto"
Install it manually:  
**Settings → Add-ons → Add-on store → Mosquitto broker → Install**

### API not responding
Check the add-on log for Python stack traces. Common causes:
- Port `28100` in use by another service (change `api_port` in options)

---

## Support

- Repository: <https://github.com/chrohrbach/casasmooth-addon>  
- Issues: <https://github.com/chrohrbach/casasmooth-addon/issues>
