# Changelog

## 2.0.21 - 2026-04-17

### Changed
- Sync published add-on metadata with casasmooth production image version 2.0.21

---

## 2.0.20 - 2026-04-17

### Added
- Remote access token (`cs_remote_token`) for opt-in remote management — written to `cs_states.yaml` via startup automation
- Nightly housekeeping job (scheduled maintenance)
- Admin energy billing email button on the Rapports dashboard
- Air quality and weather report emails

### Changed
- Manual update flow now uses `--full-restart` by default
- Rapports dashboard: limited to 3 columns
- Sync published add-on metadata with casasmooth production image version 2.0.20

---

## 2.0.18 - 2026-04-09

### Changed
- Sync published add-on metadata with casasmooth production image version 2.0.18
- Align mirrored add-on boot script comments with the production source repository

---

## 2.0.13 – 2026-03-25

### Added
- Pre-install 6 additional HA add-ons on first boot: Whisper STT, Piper TTS, File Editor, Samba, DuckDNS, Let's Encrypt
- Add-on icons (icon.png, logo.png) for HA add-on store

### Changed
- Documentation updated to reflect all 8 pre-installed add-ons
- Boot sequence comments updated

---

## 2.0.3 – 2026-02-24

### Fixed
- `is_hass_environment()` now detects addon container via `SUPERVISOR_TOKEN` (not just `ha` CLI presence) – Home Assistant core restart was silently skipped on every update cycle
- `restart_hass_core()` uses Supervisor REST API when running inside container (`ha core restart` not available)
- Whisper and Piper addon install/status checks use Supervisor REST API inside container (same root cause)
- Dev addon installation step removed from production update flow
- `cs-cameras` dashboard no longer generated when no cameras or Frigate cameras are configured

---

## 2.0.2 – 2026-02-24

### Security / Cleanup
- `texts/` (multilingual email/notification templates) now stays inside the container image – no longer copied to host filesystem
- Removed dead `embedded_data.py` module (760 lines of unused gzip+base64 blobs)
- Removed dead `templates/` folder – was never read by Python or bash at runtime

### Fixed
- `cs_services.txt` (subscription entitlement) moved from `cache/` → `locals/` so it survives cache clears and is clearly identified as persistent state
- Legacy bash updater (`cs_update_casasmooth.sh`) aligned with Python paths for `cs_services.txt`
- Boot sequence comment corrected (removed stale reference to removed step)

---

## 2.0.1 – 2026-02-20

### Security
- `app/data/` directory (rules, configuration, translations, secrets template) stays entirely inside the container image – never exposed to host filesystem
- `CS_APP_DATA` env var points to `/opt/casasmooth/app/data` inside the image
- Only `cs_logo.png` deployed from `images/` – personal/test images removed from the image

### Fixed
- `cs_update` now runs at boot with `--log --verbose` before API and MCP servers start
- `templates/` removed from host sync list (bash-only legacy, Python never reads it)

---

## 2.0.0 – Initial addon release

- First production HA addon release
- Python-based architecture replacing legacy bash updater
- MCP server on port 8003
- API server with SUPERVISOR_TOKEN authentication
