# casasmooth Add-on Documentation

> **Note**: this file is the source of truth. The copy at
> `casasmooth-addon/casasmooth/DOCS.md` is synchronised by the
> `build_addon.yml` GitHub Actions workflow on every release. Edit
> here, not there.

## Overview

casasmooth is a Smart Home configuration and automation server for
Home Assistant. It generates Lovelace dashboards, entity configurations
and automations from your device registry, manages custom components,
scripts and themes, and provisions an opinionated voice and media stack
for the subscriptions your account is entitled to.

This is the **production add-on**. The application runs from a
pre-built Docker image and is ready to use immediately after
installation.

---

## Installation

1. Add this repository to your Home Assistant:
   **Settings → Add-ons → Add-on store → ⋮ → Repositories**
   `https://github.com/chrohrbach/casasmooth-addon`

2. Find **casasmooth** in the add-on store and click **Install**.

3. Start the add-on. On first boot it will:
   - Sync static resource files to `/config/casasmooth/`
   - Install the eight required Home Assistant add-ons via the
     Supervisor API (see "Pre-installed Add-ons" below)
   - Generate casasmooth YAML / configuration files under
     `/config/casasmooth/locals/`
   - Configure the voice pipeline (Whisper STT + Piper TTS + Wyoming +
     Extended OpenAI Conversation)
   - Provision Music Assistant if your subscription includes
     `enhanced_media` (see "Music Assistant" below)

4. Open the add-on's web UI from the sidebar (it uses HA ingress on
   port 28100), or browse directly to
   `http://homeassistant.local:28100/docs` for the OpenAPI explorer.

---

## Configuration

The add-on exposes three options:

| Option | Default | Description |
|---|---|---|
| `api_port` | `28100` | Port for the casasmooth REST API server. |
| `log_level` | `info` | Log verbosity (`debug`, `info`, `warning`, `error`). |
| `dev_mount` | `false` | When `true`, swap the baked-in Python application at `/opt/casasmooth/app` for a symlink to `/config/casasmooth/app`. Lets developers edit Python sources over SSH and restart the addon for an instant reload. **Leave at `false` on client installations.** See "Development Mode" below. |

---

## Folder Structure

After installation the following directories are created under
`/config/casasmooth/`:

| Path | Purpose |
|---|---|
| `resources/` | Lovelace custom cards (copied to `/config/www/community/resources/`) |
| `custom_components/` | HA custom integrations (copied to `/config/custom_components/`) |
| `commands/` | Shell scripts used by `shell_command:` automations |
| `lib/` | Shared bash libraries |
| `images/` | Static images (`cs_logo.png` etc.) |
| `medias/` | Camera snapshots and media files |
| `locals/` | Generated YAML (`prod/`), staging (`last/`) |
| `cache/` | Performance caches (resource manifest, EID profiles, etc.) |
| `logs/` | Application logs (cs_update, voice, music provisioning) |
| `www/` | Web assets served by Home Assistant under `/local/` |

The add-on container also has read-write access to two HA-wide shares:

| Mount | HA Path | Use |
|---|---|---|
| `/media` | HA media library | Music files, camera recordings, etc. — exposed to Music Assistant when provisioned |
| `/share` | HA share folder | Cross-addon data exchange |

Application data (`app/data/`) and multi-language text templates are
bundled inside the container image and not exposed on the host
filesystem.

---

## Ports

| Port | Protocol | Description |
|---|---|---|
| `28100` | TCP | casasmooth REST API (also reachable via HA ingress, no port needed) |
| `8003` | TCP | casasmooth MCP (Model Context Protocol) server — SSE transport |

The API and MCP servers are independent processes started by the
add-on entrypoint; both are health-monitored by the Supervisor
watchdog.

---

## Pre-installed Add-ons

These eight Home Assistant add-ons are installed automatically by
`install_deps.sh` on the very first boot. Subsequent boots skip the
step (a `.deps_installed` marker is written under `/config/casasmooth/`):

| Slug | Display name | Auto-started | Notes |
|---|---|---|---|
| `core_mosquitto` | Mosquitto broker | Yes | MQTT broker for device communication |
| `core_ssh` | OpenSSH | No | Configure your public key in the add-on options before starting |
| `core_whisper` | Whisper | Yes | Speech-to-Text engine for the voice assistant |
| `core_piper` | Piper | Yes | Text-to-Speech engine for the voice assistant |
| `core_configurator` | File editor | No | Start manually from the sidebar when needed |
| `core_samba` | Samba share | No | Configure credentials before starting |
| `core_duckdns` | DuckDNS | No | Configure domain and token before starting |
| `core_letsencrypt` | Let's Encrypt | No | Configure domain before starting |

If installation of any add-on fails (transient Supervisor error,
network blip), the add-on retries on the next boot until the marker
is written.

---

## Voice Assistant

casasmooth wires a fully local-first voice pipeline on first boot,
beyond simply installing Whisper and Piper:

- **Whisper** STT (`core_whisper`) — installed and started.
- **Piper** TTS (`core_piper`) — installed and started.
- **Wyoming** integration in HA — auto-configured to point at the
  Whisper and Piper add-ons via their internal hostnames.
- **Extended OpenAI Conversation** custom component — installed under
  `/config/custom_components/`, registered as a HA integration, and
  configured to use casasmooth's LLM gateway (OpenRouter primary for
  conversational tool-calling, Infomaniak fallback for Swiss data
  residency on bulk text). The API key is read from the addon's
  secret store; no manual YAML editing is required.
- **Voice pipeline** — created with `stt.faster_whisper` + `tts.piper`
  bound to the casasmooth assistant agent. Marked as the preferred
  pipeline so the HA mobile app and Wyoming satellites pick it up
  automatically.

The whole sequence is idempotent: each `cs_update` re-runs the
configuration step and only writes when something actually drifted.

---

## Music Assistant

When your subscription includes the `enhanced_media` service, the
`provision_music` step runs during `cs_update` and:

1. Registers the Music Assistant addon repository
   (`github.com/music-assistant/home-assistant-addon`) with the
   Supervisor.
2. Installs and starts the **Music Assistant** add-on
   (`d5369777_music_assistant`) if absent.
3. Connects to MA's WebSocket API and ensures a **Filesystem (local
   disk)** music provider exists pointing at `/media/music`.
4. Copies five bundled public-domain demo MP3 files (Bach, Vivaldi,
   Satie, Mozart, Chopin — ~55 MB total, included in the addon image)
   into `/media/music/casasmooth/` so MA has a non-empty library out
   of the box.
5. Posts a persistent HA notification asking the user to open the
   Music Assistant panel **once** — this triggers MA to spawn its
   first Browser Player (`media_player.mass_*`), which is what
   unlocks the enhanced sections of the Media dashboard (Now Playing,
   Quick Moods, Music Library).

The step is idempotent and best-effort: any failure is logged to
`/config/casasmooth/logs/cs_provision_music.log` but never blocks the
update. It is a no-op when `enhanced_media` is not subscribed.

You can run it on demand without waiting for `cs_update`:

```bash
python3 -m app.cli.cs_main provision music
```

The dashboard opens the MA panel via the slug-based URL
`/d5369777_music_assistant`. To wire the four Quick Moods buttons
(`input_button.cs_media_mood_{morning,breakfast,dinner,night}`) to
actual playlists, create HA automations that listen to those buttons
and call `media_player.play_media`.

---

## Development Mode

For developers and the casasmooth dev / prod-test machines, the
`dev_mount` option (default `false`) swaps the baked-in Python
application at `/opt/casasmooth/app` for a symlink pointing at
`/config/casasmooth/app`. Effects:

- Edits to Python sources are visible after an addon restart.
- Static files are **not** re-synced from the image
  (`/config/casasmooth/` is owned by the developer).
- Same `run.sh`, same `install_deps.sh`, same boot sequence as
  production — only the location of the Python source differs.

Leave at `false` on client installations. See
[deployment.md](https://github.com/chrohrbach/casasmooth/blob/main/docs/operations/deployment.md)
for the full mode description.

---

## SSH Access

The OpenSSH add-on is installed automatically but not started. To
enable key-based SSH access:

1. Open **Settings → Add-ons → OpenSSH → Configuration**.
2. Add your public key under `authorized_keys`.
3. Start the add-on.

---

## Updates

The add-on image is versioned (`X.Y.Z`, see CHANGELOG.md). When a new
image is published to GHCR, HA notifies you in the add-on store. After
updating:

- Static files (resources, commands, etc.) are synchronised
  automatically.
- `cs_update` runs on the next boot and re-applies any new generation
  steps (orphan cleanup, voice setup, Music Assistant provisioning,
  …).

---

## Uninstall

Run the casasmooth cleanup command **before** uninstalling the add-on:

```bash
python3 -m app.cli.cs_main cleanup uninstall
```

It removes:

- The casasmooth block from `/config/configuration.yaml`
- The default dashboard pointer if a casasmooth dashboard is active
- All `cs_*` labels
- casasmooth runtime artefacts on the HA host

After that, uninstall the add-on normally from Home Assistant.

If you also want a full purge of the source tree, delete
`/config/casasmooth/` manually after uninstall. Note that
`/media/music/casasmooth/` will retain the demo MP3s; remove them
manually if undesired.

---

## Troubleshooting

### "SUPERVISOR_TOKEN not available"

Make sure the add-on has `hassio_api: true` and `hassio_role: manager`
(both are set by default in the production config). Re-install the
add-on if the option was changed.

### A pre-installed add-on did not get installed

Re-installing the casasmooth add-on triggers `install_deps.sh` again
because the marker is recreated only on success. Alternatively,
install the missing add-on manually from the HA add-on store.

### Music Assistant did not appear / Now Playing card is empty

`media_player.mass_*` only materialises **after** you visit the Music
Assistant panel for the first time (it spawns a Browser Player). Open
the MA panel from the HA sidebar, then refresh the Media dashboard.
The fallback master player (first speaker) is used until then so the
section is not empty.

### API not responding

Check the add-on log for Python stack traces. Common causes:

- Port `28100` is taken by another service — change `api_port` in the
  options.
- The HA Supervisor restarted the addon during a long generation run;
  check `/config/casasmooth/logs/cs_update.log` for the last step.

---

## Support

- Repository: <https://github.com/chrohrbach/casasmooth-addon>
- Issues: <https://github.com/chrohrbach/casasmooth-addon/issues>
