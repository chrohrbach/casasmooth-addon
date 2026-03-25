# casasmooth Home Assistant Add-on Repository

[![Add to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/chrohrbach/casasmooth-addon)

This is the official add-on repository for **casasmooth** – a Smart Home configuration and automation server for Home Assistant.

---

## Add-ons

### casasmooth

The production add-on that:

- Generates Lovelace dashboards, entity YAML and automations from your device registry
- Deploys Lovelace custom cards and custom components to Home Assistant
- Exposes a REST API (port 28100) and a Model Context Protocol server (port 8003)
- Pre-installs 8 HA add-ons on first boot (Mosquitto, SSH, Whisper, Piper, File Editor, Samba, DuckDNS, Let's Encrypt)
- Runs from a **pre-built Docker image** – source code is compiled to bytecode for protection

## Installation

1. Click the button above, or go to  
   **Settings → Add-ons → Add-on store → ⋮ → Repositories**  
   and add: `https://github.com/chrohrbach/casasmooth-addon`

2. Find **casasmooth** in the store and click **Install**.

3. Start the add-on and follow the [documentation](casasmooth/DOCS.md).

---

## Support

- Issues: <https://github.com/chrohrbach/casasmooth-addon/issues>
- Source: <https://github.com/chrohrbach/casasmooth> (private)
