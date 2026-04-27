# Changelog

## 2.0.32 - 2026-04-27

### Fixed
- Area lighting auto-off no longer skips when a user scene (1-4) is
  active. The off automation's "scene guard" now only blocks when an
  animation script (scenes 5-10) is running — animations control the
  lights and must not be interrupted, but static user scenes are
  meant to be released by the lighting timer like any other state.
  Previously, any non-zero scene blocked the timer.finished handler,
  so a single motion event during a period whose default scene was
  1-4 would leave lights on indefinitely.
- TV-scene-off no longer leaves the room dark for several seconds
  when a media player stops:
  - the unconditional `homeassistant.turn_off` of all area lights
    has been removed (it was the source of the visible blackout);
  - the area's animation scripts (5-10) are now stopped explicitly
    before handing control back to the regular lighting automation;
  - `cs_<area>_lighting_scene` is force-refreshed from the period
    config via an immediate trigger of
    `cs_parameters_<area>_update_current_values`, so the next
    enhanced/standard trigger sees the right scene number instead
    of the placeholder `0` and presses the matching restore_scene
    button (otherwise the room could stay dark up to 60 s, until
    the next minute-cycle of update_current_values);
  - the inter-step delay shrinks from 1 s to 200 ms;
  - the fallback branch (robot was off before TV) fades the lights
    out with a 1 s transition instead of an abrupt cut.

## 2.0.31 - 2026-04-21

### Fixed
- Boot no longer stalls on LLM regeneration when the instance UI bundle
  cache is invalidated by an upgrade. The `Instance UI docs` step has
  been moved out of the `cs_update` critical path into a background
  task that runs 60 s after the API server starts listening (and daily
  at 03:15 thereafter). First boot is now fast; the localised user
  guides land a few minutes later without tripping the HA watchdog and
  without triggering the restart loop that was observed on 2.0.30.

---

## 2.0.30 - 2026-04-20

### Added
- `product_shops` catalog (admin CRUD + per-language filtering) with
  URL templates using the `{product_name}` placeholder, replacing the
  per-product `specifications.online_shops` free-form JSON.
- Dedicated `crm-portal` container for `/crm/*` admin routes — the
  public website container no longer serves admin UI.
- `linked_systems` is now included in the `/api/auth/login`,
  `/api/auth/refresh`, `/api/auth/me` and MFA-verify responses so the
  tarifs page renders linked systems + plans immediately after login
  instead of depending on a subsequent `/api/auth/me` refresh.
- Stripe cancellation on system deletion: admin-initiated system
  removal now cancels every attached Stripe subscription / addon item
  before dropping the DB rows. No more orphan Stripe subscriptions
  after a cleanup.
- Support for `dev_mount` addon option to run from an editable
  `/config/casasmooth/app` tree instead of the baked image.

### Fixed
- Subscription entitlement cache consolidated into a single
  `locals/cs_services.json` file (was split between
  `locals/cs_services.txt` and `cache/services.json`, which drifted
  out of sync — the plain-text file was only ever written on first
  install, never refreshed). Legacy `cs_services.txt` is migrated
  transparently on first read and then removed.
- `/api/services` and `/api/admin/systems` now include trial-mode
  subscriptions (`status IN ('active','trial')`). Trial plans were
  previously invisible to the services resolver and to the admin
  systems list — a Premium trial system rendered as "No Plan" and
  received an empty service list.
- Fallback path when no subscription is active no longer tries to look
  up a non-existent `standard_base` *subscription* row; it now resolves
  to the Freemium plan (+ `standard_base` service) as intended.
- Ownership transfer flow rejects placeholder / malformed new-owner
  emails (e.g. the literal string `"unknown"` that some HA instances
  report before the owner sets a real address). No transfer row or
  email is created when the heartbeat reports a value without `@` and
  a dotted domain.
- System deletion cascade now covers `ClientServiceAddon` rows and the
  FK-cascaded tables (heartbeats, backups, bridging config).
- Ops-portal `DELETE /systems/<guid>/assignments/<kind>/<int:aid>`
  route no longer 500s — the function signature was missing the `aid`
  kwarg.
- Ops-portal Plans & Services editor: the "Actuellement actif" list no
  longer overlaps the editor below; items are now rendered as flex
  cards with a visible separator above "Modifier l'assignation".
  "revoke" renamed to "Révoquer".
- Assignment recap email is skipped (with a warning) when the system
  has a placeholder email, instead of letting Graph/Resend reject the
  whole batch.

### Infrastructure
- Nginx routes `/api/ownership/*` to cloud-api on all three server
  blocks (HTTP, HTTPS-FQDN, HTTPS-casasmooth.com) so claim / revert
  email links actually reach the FastAPI router. Previously
  `https://casasmooth.com/api/ownership/transfer/revert?token=…` fell
  through to the website container and returned a Flask 404.
- Cloud-api + operations-portal rebuilt with the above changes.

---

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
