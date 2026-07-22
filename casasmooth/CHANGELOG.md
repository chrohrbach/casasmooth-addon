# Changelog

## 2.0.62 - 2026-07-22

### Fixed — dashboard gating & cleanup on freemium/empty installs

- EMS dashboard is now gated on `enhanced_energy`. It used to be generated
  unconditionally and appeared in the sidebar even on freemium, where it
  has no data to drive (it is the active energy-management product: SGr
  device control, load-shifting, cost-of-mix). Returning no view makes the
  generator skip the whole `cs-ems` dashboard, so the staging→prod prune
  removes it from the sidebar too.
- System view no longer renders a "No WOL device defined" empty-state card.
  Wake-on-LAN (an `enhanced_base` feature) now shows its settings toggle,
  settings tile and section together — or all three are omitted when the
  install has no WOL entities. No stray card/toggle on freemium.
- Dropped the `cs_dummy_switch_to_avoid_errors` template switch. It had no
  backing `input_boolean`, was referenced by nothing, and surfaced as a
  stray switch entity on empty installs. The dummy *sensor* is kept — it is
  the source for the utility_meter/integration stubs and already keeps the
  modern `template:` list non-empty.
- Removed the dead "Setup guide" link (`manuals#getting-started`, a page
  that does not exist) from the empty-system Welcome panel.

## 2.0.61 - 2026-07-15

### Fixed — remote-access tunnel: never permanently give up on crash-loop

- `tunnel_service`'s `frpc` supervisor used to exit for good after 5 fast
  login failures in a row, on the assumption that the HA addon supervisor
  would restart the parent process. Nothing actually monitors this
  fire-and-forget subprocess, so a transient cloud-api blip during a
  reconnect attempt could kill remote-access connectivity permanently
  until the next full addon restart or update. Now it cools down for
  15 minutes and resumes retrying instead of exiting.

## 2.0.60 - 2026-07-15

### Feature — EMS: weather-service fallback, light/dark theme, restructure into 5 tabs

- Weather card now falls back to the HA weather service, per-metric
  (temperature/humidity/wind/pressure), whenever weather-flagged zone
  sensors are missing wholly or partially — with a `source` marker and a
  dimmed/tooltip treatment so fallback values are visibly distinguished
  from real zone readings.
- Added a self-contained light/dark theme toggle to the EMS mobile
  dashboard (was always dark), independent of the app's separate 5-theme
  picker — refactored `ems-view.css` onto CSS custom properties scoped to
  `.ems-view`/`.ems-light`, persisted via `localStorage`.
- Restructured the EMS dashboard into 5 tabs, added collapsible
  (persisted) cards across all of them, weather history as a ranged chart
  aligned to the energy timeline, richer real recommendations, help
  pastilles with tap popovers, expert mode, and a link to the hosted GRD
  simulator from the Réseau (grid) tab.

### Feature — GRD (grid operator) remote simulator, phases 0-5

- Per-system opt-in gate for remote GRD signal simulation, propagated via
  heartbeat; `sgr_webhook_token` now authenticates simulator signals over
  the tunnel; bridled duration/priority for simulator-originated signals;
  cloud-api OTP + signal relay + audit poll; real `grd_simulator.py`
  dashboard UI ported to casasmooth.net/grdsimulator, with a remote-sim
  opt-in tile and fixed silent send failures.

### Feature — Fleet Portal (multi-tenant / building-manager self-service)

- Generalized `Building` into `FleetGroup` with a login-capable manager;
  added a self-service Fleet Portal app with a real MFA challenge flow;
  group-level services override (additive, admin/portal-only), unified
  ownership-change handling, and automatic subscription cancellation on
  handover; server-side and admin-endpoint activation scripts for
  granting/revoking fleet-manager access.

### Feature — KNX (.knxproj) import tool

- Added an ETS project import tool with review/apply/rollback, redesigned
  onto EMS's visual language; fixed a missing `aiofiles` dependency and
  made the area-picker degrade gracefully when ETS data is incomplete.

### Feature — casasmooth intent triggers (purpose-specific automation events)

- Added 26 intent triggers across security, presence/access, energy/EV,
  and comfort domains, backed by a single-source-of-truth manifest and
  codegen (`intent_triggers.json` → `triggers.yaml`/`strings.json`/
  translations); migrated `telemetry.py`, `occupancy.py`, `scheduler.py`,
  and `cs_load_shift.py` onto the new `fire_intent_event()` helper. All
  verified live on `.149`.

### Fix — `cs_car` dashboard didn't recognize/display OBD-bridge or
multi-vehicle setups (6-commit cascade, all verified live on `.149`)

- The vehicle-presence gate only matched EV-with-battery-style entities;
  now recognizes anything in the `ev`/`car` registry dashboard groups, so
  OBD-bridge-only vehicles (no native cloud integration) are picked up.
- Fixed phone-consolidation logic that was silently discarding a second
  real vehicle's data behind the single Android-Auto-consolidated tile.
- Tiles are now always labelled with their device name when more than one
  source shares a metric category, and the whole page/sections/toggles are
  named after a real vehicle (native integration or OBD bridge), never a
  paired phone.
- Phone/Android-Auto tiles are dropped entirely once any real vehicle
  exists, instead of being relabeled.
- Empty category cards and their now-pointless show/hide toggles are
  hidden live via HA visibility conditions (registry has no live entity
  state to decide this at build time).

### Fix — SGr, tunnel, migration, deploy reliability

- `tunnel_service`: never permanently give up after a crash-loop.
- Migration 096's revision id was too long and crash-looped `cloud-api` on
  deploy; shortened it.
- `sgr_kpi()` crashed on `period=month/year/all` (referenced undefined
  config); `deploy-all`'s website health probe now shares the `.ps1`
  fallback; docker-compose v1 `ContainerConfig` `KeyError` on website
  recreate fixed by routing nginx at compose aliases instead of container
  names.

### Refactor — split `server.py` / `cloud_api` god-objects into routers

- Extracted `sgr_ems`, `mobile_api`, `semantic_exposure`, `assistant_chat`,
  `ai_automation_api`, `onboarding`, `validation_api`, `diagnostics_api`,
  `matter_bridge`, `floorplan_3d` (HA addon side) and `content_marketing`,
  `auth_users`, `contacts_tickets`, `admin_systems`/`admin_services`,
  `crm_billing`, `blog`, `landings`, `website_catalog`, `llm_config`, and
  the telemetry router (cloud-api side) into standalone modules; split
  `cs_automations.py` into domain modules. Internal only — no behavior
  change intended.

## 2.0.59 - 2026-07-06

### Fix — SGr audit fixes (claims summary, read_sync, MQTT connect, optimizer proxy guard)

- `sgr_rules_engine`: claims summary was reading the wrong JSON key
  (`devices` instead of `claims`), so it stayed stuck reporting "no claims";
  guarded the optimizer watts override from clobbering virtual proxy
  SG-Ready states.
- `sgr_service`: added the missing `read_sync` method (the MQTT bridge
  referenced it, but only the mock implementation had it — real devices
  never actually synced); capture the connect-time event loop for
  cross-thread dispatch.
- `server.py`: the MQTT bridge now calls `connect_all()` on devices before
  announce/publish (was always iterating 0 connected devices); aligned the
  4 inline `sgr_audit.json` event writers to append+`[-288:]`, matching the
  rules engine and readers.
- Added regression test coverage for claims summary, `read_sync`, and the
  optimizer proxy guard.

## 2.0.58 - 2026-07-06

### Fix — `sgr-commhandler` (SmartGridReady Modbus/EID library) was never installed in production

- **Root cause**: `sgr_service.py` has depended on the `sgr-commhandler` PyPI
  package since it was introduced (Modbus TCP / REST device control via EID
  XML profiles — `_connect_device`, `_resolve_eid`, etc.), but the package
  was declared **nowhere** in the real install pipeline: absent from
  `pyproject.toml` `[project.dependencies]`, absent from the addon's
  `addon/build/Dockerfile.production` `pip3 install` list (the one actually
  used to build the production image via `.github/workflows/build_addon.yml`),
  and absent from `install_deps.sh` (which only installs other HA add-ons —
  Mosquitto, SSH, Whisper, Piper — no pip packages). It only appeared in a
  docstring comment (`Requires: pip install sgr-commhandler>=0.5.0`).
  `SGrService.__init__` defensively catches the resulting `ImportError` and
  silently sets `available = False` — so instead of a loud crash, every SGr
  Modbus/EID feature was quietly a no-op in every production install. No
  Modbus/EID device (Fronius, WAGO, Kostal included) was ever proven
  functional through SGr; the test suite didn't catch it because every SGr
  test mocks `sgr_commhandler` via `sys.modules` instead of using the real
  package.
- **Fix**: added `"sgr-commhandler>=0.5.0"` to `pyproject.toml` and to the
  `pip3 install` list in `addon/build/Dockerfile.production`.
- **Test**: added `TestRealPackageInstalled` to
  `app/tests/test_sgr_library_integration.py` — the only test class in the
  SGr suite that does NOT monkeypatch `sgr_commhandler`, so a future
  packaging regression fails loudly instead of hiding behind mocks.

## 2.0.57 - 2026-07-06

### Fix — offboarding (factory reset / device cleanup) was non-functional end-to-end

- **Cloud API**: `factory_reset()` called two cloud endpoints
  (`/api/tunnel/revoke`, `/api/systems/dissociate`) that didn't exist —
  they 404'd silently and the function still reported success. Added both
  routes (`app/api/tunnel.py`, `app/api/systems.py`), authenticated via the
  system's own Bearer token. Fixed call order in `onboarding_service.py`
  (dissociate before revoke — revoke invalidates the shared Bearer) and now
  captures the cloud auth headers before wiping local tunnel state.
- **HA dashboard**: "Nettoyer les appareils" / "Réinitialisation usine"
  buttons only called `input_button.press` with no automation reacting —
  pressing them did nothing. Added `rest_command.cs_factory_reset_run` /
  `cs_cleanup_devices_run`, new loopback-only `/api/internal/factory_reset`
  + `/api/internal/cleanup_devices` endpoints, and two new automations
  wiring the buttons end-to-end. Factory reset now shows a native
  confirmation dialog (irreversible action).
- **Mobile app**: no UI existed at all for these actions. Added a
  "Maintenance" section to Settings (cleanup devices + factory reset with
  double confirmation).

## 2.0.56 - 2026-07-04

### Fix — deferred Home Assistant Core restart lost after cooldown

- **Root cause**: the add-on runs with `startup: application`, so Home
  Assistant Core always finishes loading `configuration.yaml` before this
  add-on even starts. `cs_update` regenerates the file and asks Core to
  restart to pick up changes (e.g. `http.trusted_proxies`) — but if that
  restart was deferred by the 10-minute cooldown, it was lost forever: the
  next `cs_update` run sees no NEW file diff (it already wrote the fix) and
  never re-requests the restart. Symptom: HA rejects every tunneled request
  with `400: Bad Request` / `Received X-Forwarded-For header from an
  untrusted proxy`, indefinitely, until an unrelated restart happens to occur.
- **Fix**: a persisted `cache/cs_pending_restart.json` marker now survives
  across runs. Any restart deferred by cooldown is retried on every
  subsequent `cs_update` — independent of file-diff detection — until it
  actually succeeds, then the marker is cleared.

## 2.0.55 - 2026-06-23

### Matter bridge upgrade & admin translations

- **Matter 1.4 support**: upgrade `@matter/node` from 0.12 to 0.16 — supports
  Matter 1.4.2 spec (new device types: EV chargers, water heaters, appliances,
  Scenes Management cluster, OTA updates). Explicit `colorTempPhysicalMinMireds`
  / `colorTempPhysicalMaxMireds` set for ColorTemperatureLightDevice (required
  by Matter 1.4, defaults were removed).
- **Matter bridge in dev_mount mode**: `run.sh` now runs `npm install` once on
  first boot in dev mode so the Matter bridge works without a Docker image
  rebuild. Stamp file prevents re-running on every restart.
- **Admin dashboard translations**: added 11 missing translation keys for the
  Services, Maintenance, and Matter sections (5 languages). Matter section now
  shows an explanatory text when the bridge is not running instead of a blank
  space.

## 2.0.54 - 2026-06-19

### Fix — Shelly detached mode: protect Zigbee bulbs behind wall switches

- **Detached wall_switch detection**: new `get_detached_wall_switches()` in the
  registry identifies Shelly switches that coexist with Zigbee/smart lights in
  the same area. Detection uses the Shelly `select.*_switch_type` entity
  (detached/momentary) when available, falling back to a device-id heuristic
  (wall_switch on a different device than the area's `light.*` entities).
- **Relay exclusion from lighting actions**: detached wall_switches are excluded
  from `_build_lighting_turn_on_actions`, scene save/restore, and the wallswitch
  toggle automation targets. HA no longer sends `turn_off` to the Shelly relay
  when a Zigbee bulb sits behind it — preventing mesh disconnection.
- **Relay guard automation**: a per-switch `CS - Relay Guard - <name>` automation
  re-enables the relay within 2 seconds if it is turned off accidentally (power
  glitch, firmware reset, manual override), keeping the Zigbee bulb powered.
- Wall_binary_sensor triggers (physical button press) continue to work unchanged
  — they toggle the area's `light.*` / bulbs / relay-mode switches only.

## 2.0.53 - 2026-06-18

### Fix — Security sensors & phantom-entity warnings

- **Home security section parity**: the per-area "security sensors" section on
  the home dashboard now exposes the same categories as the dedicated security
  view, from a single source of truth
  (`DashboardBase.SECURITY_SENSOR_CATEGORIES`). Door/window open sensors — plus
  water, smoke, vibration, gas, CO, tamper and noise sensors — were previously
  missing from the home view (only motion/occupancy/presence were shown).
- **Automatisations warning triangle removed**: each area's "Automatisations"
  placeholder no longer references `input_button.cs_<area>_empty_button`, an
  entity that is never created. Home Assistant rendered it as an "unavailable"
  warning (⚠️) in every area whose automation buttons are gated off (e.g. no
  lighting subscription). The placeholder is now an inert, entity-less tile.
- **Broken Low Disk Alert automation removed**: "CS - System - Low Disk Alert"
  triggered on `sensor.cs_ha_host_disk_free`, an entity that is never created,
  so HA flagged it as an unknown-entity error and it never fired. Low-disk
  alerting is already covered by "CS - System - Storage Problem Detection"
  (`sensor.system_monitor_disk_use`).

## 2.0.52 - 2026-06-17

### Maintenance

- Version bump, no functional changes.

## 2.0.51 - 2026-06-14

### Fix — Enhanced lighting: false-occupancy guard + illuminance-based turn-off

Two lighting reliability fixes, already validated in production.

- **False-occupancy guard**: every sensor-driven lighting trigger
  (motion, occupancy, presence, door/open, camera, TV) now requires
  `trigger.entity_id is defined` **and** `is_state(trigger.entity_id, 'on')`
  before acting. This stops automations from firing on an undefined or
  stale trigger context, which could switch lights on without a real
  detection.
- **Illuminance-based turn-off (hysteresis)**: new per-area automation
  that turns auto-lit lights off once ambient `avg_illuminance` rises above
  the turn-on threshold × 1.3. Closes the gap where a presence-gated zone
  kept its lights on indefinitely in broad daylight (the enhanced ON path
  only adds light and the regular OFF path only reacted to timer/sustained
  sensor-off). The 1.3 hysteresis margin prevents on/off oscillation, and
  the automation only acts in presence-gated mode while the lights are still
  owned by `auto` (never fighting a manual or scene override).

## 2.0.50 - 2026-06-07

### Fix — template integration off the deprecated `platform:` key

Home Assistant core (2026.6) no longer supports configuring the template
integration via the legacy `sensor: - platform: template` /
`switch: - platform: template` keys.

- All real template sensors/switches already used the modern `template:`
  integration; only the internal dummy entities
  (`cs_dummy_sensor_to_avoid_errors`, `cs_dummy_switch_to_avoid_errors`)
  were still emitted as legacy `- platform: template`.
- Those dummies are now generated under the modern `template:` integration,
  and `cs_sensor.yaml` / `cs_switch.yaml` are emitted as valid empty lists.
- No functional change for end users; clears the "Unsupported YAML
  configuration for the template integration" repair warning.

## 2.0.49 - 2026-05-24

### Security — Round 7 + Round 8 + Round 8 Niveau 2

Continuation of the 2.0.48 lockdown. Three further rounds of hardening,
plus an MFA reminder on the addon side. No functional change for end users.

**Round 7 — security-advisor MFA reminder (HA-side)**
- New advisor flow detects interactive HA accounts that haven't enrolled
  in TOTP and nags via persistent notification + email. Filters out
  `system_generated` accounts (Supervisor, Cast bridge, ...) and reads
  the correct HA 2024+ auth schema:
  `auth.data.credentials[].user_id` (top-level array) + the singular
  `auth_module.totp` storage file.
- i18n: 6 new keys in `cs_translations.csv` (FR/EN/DE/IT/CS).
- Three-layer anti-spam on the camera-offline advisor: 15-min
  `binary_sensor` debounce + 2-min trigger `for:` + 6-hour cooldown.

**Round 8 — HA LLATs encrypted at rest on the cloud DB**
- `app/utils/secret_box.py`: Fernet wrapper with `enc:v1:` prefix and
  `MultiFernet` rotation support. `cryptography>=42` added.
- Migration 085 encrypts existing `systems.remote_token` in place and
  scrubs the duplicate copy that was leaking into `systems.extra_data`
  via the heartbeat merge.
- Pydantic `field_validator` on `SystemResponse.remote_token` so every
  endpoint that returns the model decrypts on the way out.
- `STRICT_API_AUTH` boot guard: cloud-api returns 503 on `/health` when
  either `CASASMOOTH_DB_FERNET_KEY` or `STRICT_API_AUTH` is missing, so
  monitors page on misconfiguration.
- `cs-deploy` learned both env vars + a `_ensure_fernet_key` helper that
  auto-generates a Fernet key on first deploy and persists it to depot
  at `casasmooth-internal/db_fernet_key`.
- Removed the hard-coded `ADMIN_WEB_PASSWORD` default
  (`csadmin!0301040105`) from operations-portal + compose — it was
  readable from the repo.
- Verified in prod: 13/13 `systems.remote_token` rows are `enc:v1:` at
  rest, 0 plaintext leftover in `systems.extra_data`.

**Round 8 Niveau 2 — per-admin accounts + TOTP MFA + audit log**
- Shared `csadmin` / `ADMIN_TOKEN` retired in favour of per-admin
  identity. Admins live in `website_users` (role=`admin`),
  `password_hash` is PBKDF2, `totp_secret` is Fernet-encrypted at rest.
- Migration 086: `admin_audit_logs` records every admin mutation
  (action, target, method/path, status, IP, user-agent, admin identity).
  FastAPI middleware auto-appends one row per `/api/admin/*` +
  `/api/systems` write.
- `admin_api_tokens` stores per-admin API tokens (sha256 only).
- Two-step login (email+password → TOTP) on `/portal/login` and
  `/crm/login`. Lockout after 5 consecutive failures.
- New CLI: `python3 -m app admin {create|list|reset-totp|reset-password|token|audit}`.
- Three admins provisioned + verified live (crohrbach@teleia.ch,
  lrohrbach@teleia.ch, christine.rohrbach@hotmail.com).

## 2.0.48 - 2026-05-22

### Security — full backend lockdown (6 audit rounds, ~40+ vulnerabilities closed)

This is a security-only release. No functional change for end users; the
addon should pull and restart transparently.

**Per-system Bearer auth on cloud-api**
- `Authorization: Bearer <token>` (the cs-remote tunnel secret, already on
  every HASS at `/data/tunnel/frpc.toml`) is now required on:
  `/api/files/{backup,restore,list}`, `/api/secrets`, `/api/email/send`,
  `/api/diagnostics`, `/api/heartbeats/{guid}`, `/api/metrics/llm`,
  `/api/audit/llm`, `/api/telemetry/reports`, `/api/tunnel/slug`,
  `/api/systems/{guid}/migration/confirm`, `/api/llm/config` (GET),
  `/api/systems/{guid}` (GET), `/api/subscriptions/{guid}`,
  `/api/services/{guid}`, `/api/tunnel/provision` (when re-fetching
  frps_token for an already-provisioned system).
- Constant-time `hmac.compare_digest` on token comparison.
- Anti-brute-force auto-lock: 50 fails from a single IP OR 200 globally
  per hour (was 10 across all IPs — a known guid + cheap script could
  lock any tenant's tunnel).

**Admin-only on cloud-api writes**
- `GET /api/systems` list, `PUT /api/bridging/{guid}`,
  `POST /api/llm/config`, `GET /api/llm/config/history`, all `/api/admin/*`.

**HASS-side (server.py) AuthMiddleware**
- Tunnel traffic (`<guid>.casasmooth.net`) no longer satisfies
  `is_internal_host` or `X-Casasmooth-Context: lovelace` bypasses — both
  short-circuited the entire cs API auth.
- `/api/internal/*` removed from PUBLIC_PREFIXES (was allow-listed with a
  fake "guarded by localhost check"). An attacker could call
  `/api/internal/sync_csadmin_password` via the tunnel to RESET the HA
  admin password. Now AuthMiddleware enforces loopback + RFC1918 origins,
  and `sync_csadmin_password` adds a hardened
  `_verify_internal_request_origin` defence-in-depth.
- `POST /api/auth/config` (the disable-the-whole-middleware switch) is
  now loopback-only.
- CORS regex tightened — `allow_origins=["*"] + allow_credentials=True`
  (spec violation) replaced by a regex that accepts only
  `*.casasmooth.net` + RFC1918 + .local.

**Side services**
- rules-service: HTTP middleware gates every admin path;
  `/api/entities/{report,uncategorized}` require per-system Bearer.
- logs-service: `POST /api/logs` requires Bearer; reads + management
  endpoints require admin.
- upload-web (`/upload/api/*`): was UNAUTHENTICATED with path-traversal
  on `csuuid` — now Bearer per-system + UUID-regex + filename
  sanitisation + resolved-path containment.
- image-ai (`PUT /api/camera/upload`): strict devuuid regex (rejects
  `..`) + enrolment check + 50 MB cap.

**Token mirror**
- `tunnel_service` mirrors the per-system token at boot to
  `/config/casasmooth/locals/cs_tunnel_token` (mode 0600). HA Core /
  shell_command callers (which can't see the addon's `/data/tunnel/`)
  read it from there. Done BEFORE frpc binary check, so the file appears
  within milliseconds of addon start (avoids race with `cs update`).

**Heartbeat payload guard**
- POST /api/heartbeats caps each capability model (semantic / gap /
  functional) at 10 MB (was unbounded → DB-pollution / DoS risk).

**Infrastructure**
- Azure PG firewall: removed `AllowAzureServices` (was allowing every
  Azure tenant) — kept only the VM IP + admin IP.
- Azure PG admin password rotated; pushed to depot
  (`azure-cloud/db_password`) and propagated to the VM `.env`.
- nginx rate-limiting added in repo (heartbeats / login / files /
  api_general) — deferred deploy until the Infomaniak migration is
  complete (current Azure default.conf has diverged).

**Tooling**
- New `cs-deploy github sync-secrets` — pushes depot secrets
  (ADMIN_TOKEN, LOGS_SERVICE_URL) into GitHub Actions repo secrets so
  workflows like `analyze_logs.yml` can authenticate against logs-service.
- `scripts/dbcheck.py` no longer carries the DB password in cleartext;
  resolves DATABASE_URL from depot.

**DB cleanup**
- 34 stale systems (last_seen <2026 OR never-seen) removed via the
  proper `DELETE /api/admin/systems/{id}` cascade.

## 2.0.47 - 2026-05-22

### Lighting exception — fix scene-to-scene transitions in contiguous schedules
- **Bug**: in `cs_parameters_<area>_update_current_values` (UCV), the two
  template triggers `{{ ns.scene > 0 }}` and `{{ ns.scene <= 0 }}` only fired
  on the boolean's `false→true` edge — not on changes of the underlying
  `ns.scene` integer. With contiguous schedules like
  `s1:8-9 s2:9-18 s3:18-22 s4:22-23`, every internal boundary (09:00,
  18:00, 22:00) was silently skipped: the boolean stayed `True` across
  the transition, so HA never re-evaluated UCV and the new scene's
  `restore_scene_<N>` button was never pressed.
- **Observed on Lykke 2026-05-22**: s1→s2 at 09:00 was missed on all 7
  areas. Anne had to manually click `restore_scene_2` on each area at
  09:37 (and again 2 of 7 areas at 08:34 because the s1 batch had been
  partial). Same root cause across the whole client fleet using
  multi-window day schedules.
- **Fix** (`app/core/cs_automations.py`): replace the 2 boolean triggers
  with 11 targeted ones — `{{ ns.scene == 1 }}` … `{{ ns.scene == 10 }}`
  (one per scene) plus a single close `{{ ns.scene == -1 }}`. Each fires
  its own rising edge as `ns.scene` enters its window, including the
  s1→s2, s2→s3, … transitions. First-match-wins overlap semantics in the
  Jinja parser are unchanged.
- **Validation on .149 bureau** (test schedule `s1:11:07-11:08 s2:11:08-11:09`):
  - 11:07:50 → `restore_scene_1_in_bureau` fired (window open ✓)
  - 11:08:09 → `restore_scene_2_in_bureau` fired (contiguous transition ✓
    — would never have fired with the old triggers)

## 2.0.46 - 2026-05-22

### Remote tunnel — fix multi-tenant proxy name collision
- **Bug**: every frpc rendered `name = "hass" / "cs-api" / "mcp"` in its
  `frpc.toml`. In frps, the proxy `name` is a server-global key, so the
  second client to connect was rejected with
  `new proxy [hass] error: proxy [hass] already exists`. With 14 systems
  declaring `tunnel_status=connected` in DB, **0** had a working HTTP
  route — including `.149` (the Phase 1 reference). Every public host
  (UUID and slug) returned 404 `no route found` at frps.
- **Fix** (`app/services/tunnel_service.py`): prefix each proxy name with
  the system GUID so frps sees a unique key per client:
  `name = "{guid}-hass"` (resp. `-cs-api`, `-mcp`). The auth plugin
  (`/api/tunnel/auth`) does not key on proxy name, so the change is
  transparent server-side; nginx → frps vhost routing is by host header
  only, also unaffected.
- **Rollout**: `.149` (dev_mount) picks up the new template on next addon
  restart. Real clients (Lykke, Etoy, Chalet, Domenbach, …) need this new
  image; frps is restarted to purge phantom proxy registrations.

## 2.0.45 - 2026-05-22

### Frigate / camera health alerts — admin-only (no more client emails)
- **Bug**: three technical alerts emailed/notified the client even though
  they are pure admin/maintenance concerns:
  - `CS - Surveillance - Frigate Offline Notification` — sent an explicit
    email to `info@casasmooth.com` AND a `_create_notification_actions(PAM)`
    block whose `M` channel routed a second email to
    `input_text.cs_user_email` (the client).
  - `CS - Surveillance - Frigate Auto Restart` (escalation branch on
    excessive restarts) — same double-send pattern.
  - `CS - Security - Camera Offline Alert` — had **no** admin email at
    all, only a `PAM` block notifying the client (dashboard + app + email).
- **Fix** (`app/core/cs_automations.py`):
  - Drop the `_create_notification_actions(...)` block on all three.
  - Keep / add a single `rest_command.cs_send_email` targeting
    `info@casasmooth.com`, with the customer's email surfaced in the
    subject and body for triage.
  - Client now receives **zero** dashboard / app / SMS / email signal on
    Frigate Offline, Frigate Excessive Restarts and Camera Offline.
- **Out of scope** (unchanged): security alarms, lock failures, freezer
  alerts, Low Disk and Getservices Stale — those remain customer-visible
  per existing UX.

## 2.0.44 - 2026-05-19

### Per-area config cards — gate aligned with automation sensor union
- **Bug**: room-level config cards (Lighting / HVAC / Security) only opened
  on a subset of the sensors their underlying automations actually use. A
  room with **only** an mmWave radar (`presence_sensors`) — or **only** a
  vibration sensor for security — had the corresponding "Paramètres" panel
  hidden even though the automation worked.
- **Fix** (`app/core/dashboards/cs_home/cs_home.py`):
  - **Lighting**: fetch `presence_sensors` at the call-site and pass a new
    `has_persistent_presence` flag. The "Automations avancées" gate is now
    `motion ∪ open ∪ occupancy ∪ presence(mmWave)` — same union as
    `cs_automations.py` `all_devices`. `is_mixed_zone` corrected to use the
    flag (was using the multi-zone-filtered list). Redundant `has_camera_sensors`
    OR removed (camera is a subset of motion).
  - **HVAC**: `area_presence` now includes `presence_sensors` — matches
    `cs_automations.py` heating `presence_sensors = motion + occupancy + presence`.
  - **Security**: `area_security` now includes `presence_sensors` and
    `vibration_sensors` — matches the "Verify security sensors" automation
    triggers. Smoke / heat / moisture / noise stay out (notification-only,
    no UI to configure).

## 2.0.43 - 2026-05-19

### Security view — occupancy + presence sensors restored
- **Bug**: 5 call-sites queried `all_occupancy_sensors` as if it were a
  meta-aggregate, but `cs_rules.csv` only assigns this category to
  Frigate "all occupancy" virtual sensors. All other occupancy-tagged
  sensors (IKEA Matter MYGGSPRAY, IKEA Zigbee VALLHORN, Philips Hue
  SML003, Frient MOSZB-153, Aqara FP2…) fall under the generic
  `occupancy_sensors` category and were never reached by the security
  dashboard or security automations.
- **Fix**: aligned the 5 call-sites on the existing atomic-enumeration
  convention (`motion_sensors` + `occupancy_sensors` + `presence_sensors`)
  used everywhere else in the codebase.
  - `cs_security.py` — section "Présences" of dashboard Sécurité,
    recommendations engine relevant_categories.
  - `cs_home.py` / `cs_dashboards.py` — area_security tile.
  - `cs_automations.py` — camera occupancy fallback + per-area
    `verify_security_sensors` automation triggers.
- **Data files** — renamed `all_occupancy_sensors` → `occupancy_sensors`
  in `feature_requirements.json`, `site_context.json`, `chat_knowledge.json`,
  `cs_translations.csv`, plus the website mirrors. Added the missing
  `help_device_presence_sensors` translation. `cs_rules.csv` rule 164
  (Frigate-specific) kept intact.
- **Effect**: occupancy/presence sensors now feed (a) the "Présences"
  section of the security dashboard, (b) the per-area
  `verify_security_sensors` automation that increments the global event
  counter, (c) the recommendations engine. The lighting path already
  used the atomic category name and is unchanged.

## 2.0.42 - 2026-05-17

### LLM gateway — cloud-managed routing
- **Infomaniak primary + OpenRouter fallback** rolled out across all
  purposes (chat, conversation, translate, recommendations, blog,
  catalog, rules, features). Per-provider circuit breaker, per-purpose
  provider chain, provider-aware metrics. Ministral-3 14B replaces
  Apertus everywhere on Infomaniak (Apertus 20k context overflowed on
  long prompts).
- **Cloud-managed routing config**: the per-purpose model map is now
  edited in the operations portal and pushed to addons — no addon
  redeploy needed to retune chat/conversation models. Editor seeds from
  baked-in defaults when DB is empty; portal page gains
  provider/call_type/model filters on `/llm-metrics`.
- **Weekly model-availability monitor**: cron at Mon 08:00 UTC mails an
  advisory report to info@casasmooth.com (replaces the GH Actions
  workflow).
- HA Extended OpenAI Conversation now routes through the casasmooth
  gateway. OpenRouter chat model switched to `deepseek-chat`.

### Voice assistant (Jarvis / Assist) — accuracy hardening
- **Zone-filtering**: prompt now only includes the area(s) mentioned in
  conversation instead of dumping the whole house.
- **Per-area sensor section** with **UoM-first classification**:
  semantic model enriched from the entity registry, locale-independent
  unit-of-measurement → category map, FR/EN name tokens dropped. Unit
  shown in prompt. Fixes "0 lux" hallucinations on FR-named sensors.
- **Anti-hallucination guards**: new `get_entity_state` template tool
  (was referenced by prompt but missing); prompt now mandates calling
  it before any state claim; anti-sycophancy rule + context continuity.
- **Sensor filtering**: nightly `_sleep_avg_` aggregates excluded from
  both prompt sensor section AND HA exposed_entities (single
  `_is_realtime_for_llm` predicate). Prevents DeepSeek from hallucinating
  tool names against stale aggregates.
- **Topic policy** broadened with weather examples; web-search wired
  via `cs_search_web_technical`; tool rename
  `search_casasmooth_website` → `casasmooth_help` (LLMs were collapsing
  the double-s on the old name).
- **STT fallback to HA Cloud** on CPUs without X86_V2 (faster_whisper
  crashloop on Proxmox kvm64 default).
- **Devices grouped by semantic category**, not HA domain, in prompt.
- **Voice/conversation model swap**: chat_model now sourced from the
  dedicated `CASASMOOTH_ASSISTANT_MODEL` secret. Fix: setup_voice
  (step 15) no longer overwrites setup_conversation (step 14).
- KB recompiled + prompt hardened for the site chat as well.

### AI Automations — IR-based v2
- New triggers/conditions/actions schema with arbitration, package
  helpers, and boot-time sync. End-to-end wiring: HA Core tool
  dispatch, unique IDs, registry preload, manual trigger path.
- **Voice-driven CRUD**: `quick_create_ai_automation` (draft+confirm in
  one tool), `bulk_delete`, slugified entity_id for test_run.
- Arbiter release on delete/disable. Persistent path. ai_custom
  lighting rank. Owner entities + REST endpoints.

### cs-deploy — unified CLI
- New `cs-deploy` Python CLI replaces the PowerShell + Bash deploy
  scripts. `deploy-all` command (combined Azure + HASS + health).
  Containers cmd parameterized for Azure + Infomaniak.
- `blob_migrate` + `maintenance` modules for the Azure → Infomaniak
  cutover. Cron sync module (idempotent BEGIN/END markers).
- SCP fallback via `ssh cat` for SCP-disabled hosts (.149); utf-8 +
  `errors=replace` on captured subprocess output.

### docs/build — unified content pipeline
- Generic pipeline orchestrator + `build_content` for presentation,
  technical, website. Hash-cache, separated config/output, depot vault
  lookup. Brand-aligned HTML/PPTX rendering. Source fragment hints +
  larger context window. Switched to gemini-2.5-pro.

### Cloud-api Phase 2
- Eliminate `SecretsCacheService`; secrets served from disk.
- Logs-triage Phase A: promotion filters + bulk-ignore.
- CI: stop cascading website redeploys + public-URL watchdog.
- Watchdog log: clean failure-code formatting (000000 → 000).
- Migrate Azure-specific FQDN to `api.casasmooth.net`.

### Energy / SGR
- Add management summary for the energy domain.
- SGR: align with SmartGridReady spec, add MQTT discovery bridge.

### Misc fixes
- **Frigate addon**: dynamic slug + Supervisor REST replaces broken
  `ha addons restart`.
- **Billing**: replace "TVA incluse"/"TTC" → "Sans TVA" across site,
  CRM, emails and quotes.
- **Voice notifications**: Jinja2 broken on gas alerts + dedup 3
  hardcoded TTS blocks.
- **API**: remove duplicated `/api/matter/entities` endpoint.
- **Zone-scene UI**: title global panel + disambiguate duplicate zone
  labels.
- **nginx**: route `/api/*` directly to image-ai for ESP32 cameras.
- **Ops**: close cleanup gap — disk hit 100% + cs-deploy was not
  shipping crons.

## 2.0.41 - 2026-05-11

### Lighting — extinction strategy overhaul
- **Categorization rules (cs_rules.csv)**: VALLHORN / MYGGSPRAY / SML00x
  now categorized strictly from HA `device_class` (motion → motion_sensors,
  occupancy → occupancy_sensors). Removed brittle brand-override rules.
  SNZB-06P split into dc-based rules. MQTT generic motion rule routes to
  `motion_sensors` instead of the dead-end `remote_motion_sensors`
  category (the latter is no longer referenced by code). Rules snapshot
  v13 published to rules-service (363 rules total).
- **Removed the motion-fallback guard** in enhanced lighting. Motion and
  occupancy sensors trigger ON independently. Previously, motion was
  gated as a fallback that only fired when all persistent sensors were
  unavailable — that gate hid PIR misses behind unreliable occupancy.
- **New Optimise switch** (`input_boolean.cs_<area>_lighting_optimise`)
  per MIXED area (zones with both a timer source and a persistent
  source). `off` (default) = extinction by configured delay (timer-based).
  `on` = extinction by occupancy state + 2-min sustained-off.
- **Sustained-off as fallback (fix bain stuck-on bug)**: in MIXED zones
  with Optimise=off, if entry occurred via a persistent sensor only (no
  motion/camera/door, so no timer was started), sustained-off triggers
  are still honored — lights extinguish via the slider-configured delay
  applied to the occupancy `for:` window. Without this fallback, MIXED
  zones with persistent-only entry stayed lit indefinitely.
- **Unified delay slider semantic**: `cs_<area>_lighting_delay` (and its
  per-period variants) is now visible in *every* zone with an extinction
  source. The slider drives both the timer duration (timer-source zones)
  and the sustained-off `for:` duration (persistent-source zones), via a
  templated state trigger. Previously, persistent-only zones (atelier,
  cave, garage, exterieur on Chalet) had a hardcoded 2-min extinction
  and the slider was hidden — leading to UI inconsistencies and no way
  to tune the extinction window.
- **Skip off-automation for no-trigger zones** (e.g. `deco`): previously
  generated a dead-code automation with `timer.finished` as the only
  trigger; now skipped entirely.

### Functional model
- `services_manifest.json` regenerated (254 references, +2 vs prior):
  picks up the new `remote_access` service and the
  *"Configurable extinction strategy per MIXED area"* feature, attached
  to both `standard_lighting` and `enhanced_lighting`.
- `cs_functional_model.json` regenerated from the manifest.

## 2.0.40 - 2026-05-11

### Remote access
- Phase 1 deployed on .149: per-system tunnel tokens, frps auth plugin
  in cloud-api, and an in-addon `tunnel_service` spawned from
  `server.py` lifespan so each HA instance is reachable as
  `https://{ha_uuid}.casasmooth.net` without operator intervention.
- Tunnel cutover follow-ups: token rotation hooks, watchdog, retry
  back-off, and clean shutdown sequencing.
- `cs_administration` dashboard now surfaces the read-only tunnel URL
  for the current system so support can copy-paste it without going
  through the cloud portal.

### Media
- MA player detection rewritten: instead of pattern-matching `mass_*`
  in the entity_id, the dashboard reads the HA entity_registry and
  picks players whose integration `platform == music_assistant`. Fixes
  Now Playing on installs where the user renamed the MA player or where
  `cs_rules` has no `music_assistant` entry yet.
- Quick Moods (fixed 2×2 buttons) replaced by **dynamic top-10 MA
  playlists** rendered as tap-to-play tiles. Falls back gracefully when
  MA exposes fewer than 10 playlists.
- Media view sections reordered to: Library, Now Playing, Playlists,
  MA, Players, TVs. Settings tiles in the same view follow the same
  order so the configuration UI mirrors the rendered layout.
- Category sections deduplicate `mass_*` players that already appear
  in the dedicated MA section.
- Music Assistant addon is now installed with `boot=auto`, watchdog,
  ingress_panel, and `auto_update=true` so support doesn't have to
  babysit MA upgrades after first provision.
- Persistent HA notification when MA has no exposed player is clearer
  about the one-time `expose_to_ha` step required.

### Fixes
- `camera_process_snapshots` API endpoint crashed with
  `pattern=None` when called without a filename pattern, which had
  silently stalled the snapshot pipeline since 2026-04-18 — files were
  piling up in the cache instead of being processed.
- Daily-time camera filenames now use the `area_id` slug instead of
  the localized `area_name`, matching the convention already used by
  the frequency-based path. Avoids broken paths on French / German
  installs where area names contain accents or spaces.

### Repos / Build
- `endpoint/` (ESP32-S3 4G camera firmware, ESPHome cameras,
  MicroPython sensors) split out to a dedicated
  [`chrohrbach/casasmooth-endpoint`](https://github.com/chrohrbach/casasmooth-endpoint)
  repository. All `casasmooth_endpoint` legacy references dropped from
  this repo (paths, scripts, docs).
- `addon/build/DOCS.md` is now the source of truth for the HA Add-on
  Store description; the workflow mirrors it to
  `casasmooth-addon/casasmooth/DOCS.md`. Content extended with Music
  Assistant integration, voice setup, and dev mode notes.

## 2.0.39 - 2026-05-10

### Added
- Enhanced Media dashboard rework: when `enhanced_media` is in the
  subscription, three new sections appear at the top of the Media
  view. **Now Playing** is a hero `custom:mini-media-player` bound to
  the best available player (preferring `media_player.mass_*`, falling
  back to the first speaker, then any `media_player`). **Quick Moods**
  is a 2×2 grid of tap-to-trigger tiles wired to four
  `input_button.cs_media_mood_{morning,breakfast,dinner,night}`
  helpers (installer wires the actions in HA automations). **Music
  Library** is a markdown intro plus a button that navigates to the
  MA addon panel at `/d5369777_music_assistant`.
- Auto-provisioning step `provision_music` in cs_update (idempotent):
  registers the Music Assistant addon repository with Supervisor,
  installs and starts the MA addon if missing, opens a WebSocket to
  MA and ensures a Filesystem provider points at `/media/music`,
  copies the bundled public-domain demo MP3s into
  `/media/music/casasmooth/`, and posts a persistent HA notification
  when no `media_player.mass_*` exists so the user knows to open the
  MA panel once (which spawns a Browser Player). No-op when
  `enhanced_media` is not subscribed; failures are logged and never
  block the update.
- 5 public-domain demo MP3 files bundled in
  `app/data/demo_media/casasmooth/` (Bach Brandenburg 6, Vivaldi
  Spring, Satie Gymnopédie 1, Mozart Eine kleine Nachtmusik, Chopin
  Klavierwerke; ~55 MB total). All sourced from Internet Archive
  recordings whose composers and performers are in the public domain.
  Companion script `internals/fetch_demo_media.py` resolves
  identifiers via the IA metadata API so a refresh or replacement is
  one command.
- CLI `python3 -m app provision music` runs the MA provisioning
  workflow on demand for support / one-shot scenarios.
- FR / EN / DE / IT / CS translations for the new media keys
  (`ui_now_playing`, `ui_quick_moods`, `ui_music_library`,
  `ui_music_library_intro`, `ui_open_music_library`,
  `ui_mood_*`).

### Changed
- `enhanced_active` no longer requires `media_player.mass_*`; the
  enhanced sections render as soon as the subscription is present,
  with the Now Playing card pointing at a sensible fallback. Avoids
  shipping an empty Media view to enhanced_media subscribers before
  MA has spawned its first Browser Player.
- Quick Moods tiles use `hide_state: true` + `vertical: true` and
  call `input_button.press` explicitly, so the default
  `last_triggered` "Il y a X secondes" noise no longer pollutes the
  dashboard.

### Lighting
- C1–C11 hardening sequence on the lighting evaluator. C1 introduces
  a dedicated `lighting_eval` timer plus a boot reset of orphan
  rank-2 sources. C2 extracts per-scene apply scripts
  (`script.cs_<area>_apply_scene_<s>`) and lets the system path
  bypass the `scene_memo` claim that was breaking loops. C3–C6 move
  the model from a `/30s` polling automation to event-driven
  triggers (TV / illuminance / UCV state changes) gated by the eval
  timer, with a 30 s boot grace. C8 debounces TV state triggers and
  excludes `unavailable` artefacts. C9 simplifies TV triggers to
  `playing` / `on` / `off` / `standby` only. C10 aligns the
  `standard_lighting` TV triggers with C9. C11 adds a mid-sequence
  presence bail in the off automation.
- TV scene logic simplified: presence-driven inline override, UI
  selector reduced to 0–4.
- `enhanced_lighting` now fires on TV state changes (timer-gated) so
  the TV scene applies in motion-only areas like `mansarde`.
- Registry: cast Chromecasts whose name contains `_tv*` are now
  classified as TVs so they correctly trigger TV scenes.

### Performance / Recorder
- Recorder Phase 1 exclusions: high-frequency SCB / cs_power / Bambu
  / Apollo / plug-voltage sensors are now excluded from the recorder.
  Long-term statistics survive (the exclusion is on `state`, not on
  `statistics`). Significant reduction in DB churn and
  `home-assistant_v2.db` growth.
- UCV (`update_current_values`) state-driven refactor: the
  per-area `cs_<area>_update_current_values` automation no longer
  fires on a `time_pattern` of `/1`; it now uses
  state / time / template triggers. Cuts ~73 k UCV fires/day across
  25 areas while propagating period and parameter changes
  instantly.

### Rules & Detection
- IKEA + Hue motion matching consolidated across Matter / ZHA /
  Z2M. The classifier now keys on manufacturer rather than model,
  which covers truncated Matter names (`MYGGSPRAY`, `VALLHORN`),
  Z2M part-number variants, and the DIRIGERA empty-model edge case.
- Frigate restart alerts are now forwarded to `info@`.
- Quality-gate noise from `notifications.get_secret('guid')` is
  silenced via `log_missing=False`.

### Cloud / Infrastructure
- Cloud API endpoints migrated to `api.casasmooth.net` (Phase 5).
- Heartbeat metadata now reads the version from the `VERSION` file
  rather than a hard-coded constant. `OPENROUTER_CHAT_MODEL`
  switched to `deepseek` (the previously configured `nemotron:free`
  model became unreliable).
- Security: hard-coded GitHub tokens removed from the source tree;
  legacy `Dockerfile` retired (only `addon/build/Dockerfile.production`
  remains).
- `cs_secrets.yaml` master no longer tracked in git (was committed
  in error in an earlier commit; history retains the file but no
  new commits will include it).

### API
- Public `/api/website/catalog.csv` endpoint plus internal project
  quote tooling under `internals/`.

### Docs
- OBD telemetry bridge spec v2 added; `OBDLink CX` is the new
  reference adapter.

## 2.0.38 - 2026-05-05

### Added
- Standalone `cs_lighting` dashboard, gated on the `enhanced_lighting`
  subscription, visible in the sidebar for all users. One section per
  area: 3-column lights grid with `more-info` panel on tile body click
  (brightness/color), 6×2 scenes grid with 100% + scenes 1-4 + suspend
  on row 1 and FX scenes 5-9 on row 2 (suspend rendered same size as a
  scene button), and a per-area unavailability banner driven by a real
  `template binary_sensor.cs_<area>_lighting_any_unavailable`. The banner
  card is wrapped in a `condition: state` conditional card so it
  collapses entirely when no fixture is unavailable (HA conditional
  cards do not support `condition: template`, hence the binary sensor
  indirection). Empty grid cells render borderless — no placeholder
  markdown — matching the cs_home look.
- Multi-provider LLM gateway in `app/utils/llm.py`: Infomaniak (Swiss
  data residency) primary for bulk text purposes (chat, translate,
  recommendations, blog, catalog, rules, features); OpenRouter fallback
  for tool-calling-heavy purposes (conversation) and premium narrative
  (ui_docs via Claude Sonnet) and vision (Gemini Flash). Per-provider
  circuit breaker, per-purpose provider chains, env-var overrides.

## 2.0.37 - 2026-05-04

### Added
- Registry orphan cleanup: new `OrphanCleanupManager` detects helper /
  automation / script entities that previous releases generated but
  the current generation no longer emits, and removes them via the HA
  WebSocket API (`config/entity_registry/remove`). All deletions are
  audit-logged to `logs/cs_orphan_cleanup.jsonl`. Safety rails: only
  `cs_*`-prefixed entries, skips user-disabled / hidden entries,
  refuses to flag a domain whose generation YAML is missing or
  smaller than 1 KiB, hard cap on deletions per run. Exposed as
  `python3 -m app cleanup orphans [--apply] [--list] [--domain X]
  [--max-deletions N] [--yes]` for manual runs, and wired into
  `cs update` as a final step before restart with a per-cycle cap of
  2000 so a large backlog drains gradually. Validated on a long-lived
  production install: 13 146 stale entries removed, 0 errors.
- Power outlets surface as a dedicated section in each area view on
  the Home dashboard.
- New `cs_<area>_vacuum_resume_automation` resumes any vacuum stuck
  in `paused` state for 10 minutes (manual pause, recoverable error).
  The presence-triggered send-home automation now skips when any
  vacuum is already paused, leaving recovery to the resume automation.

### Changed
- Energy dashboard renders even when only one individual consumer is
  configured (previously fell back to the empty-state). Every section
  is now gated on its actual prerequisites — Date / Distribution /
  Sources table / Indicators / Details / Sources tiles only render
  when their backing PV / grid / battery / consumption sensors exist
  — so the view never shows an empty HA Energy built-in card. The
  redundant Consumers / Consumers history / Devices sections
  wrapping HA's `energy-devices-graph` were dropped (they duplicated
  the rule-based Consumers section that was already gated correctly).
- Lighting 100% / 50% / Auto buttons (and their backing automations)
  are now generated for any area with at least one lighting entity,
  not just multi-light areas. Keeps the UI row layout consistent
  and removes the "missing button" surprise on small areas.
- Enhanced lighting / heating / vacuum automations now recognize the
  `presence_sensors` registry category (typically mmWave /
  `device_class=presence`) as persistent presence alongside
  occupancy: included in the OR-conditions, in the periodic
  `time_pattern` re-evaluation, and in the 2-minute sustained-off
  trigger of the lighting-off automation. Motion sensors stay
  edge-based and remain a fallback when all persistent sensors are
  unavailable / unknown.

### Removed
- Dead, unsafe code in `cs_registry.py` that wrote directly to
  `/config/.storage/core.entity_registry`
  (`enable_entities` / `unhide_entities` / `_save_entity_registry`).
  These had zero call sites and would have raced HA's in-memory
  cache. The safe equivalents in `HassApi` (which go through
  `config/entity_registry/update`) are unaffected.

## 2.0.36 - 2026-05-03

### Added
- Booking SPA: shared `BookingCalendar` picker — 30-min calendar grid
  (days × times), multi-slot selection with `+` / `−` buttons, an
  orange selection bar that spans the actual booked duration, an
  `Ajouter le prochain créneau` shortcut, and a `Réserver maintenant`
  shortcut on the zone QR landing when the zone is currently free.
- Picker filter strip: `À partir du` date stepper and `Pas avant` time
  stepper (custom 24h widgets — "Mai 5" / "08:00" — so the rendering
  is locale-agnostic), weekday chips (`Tous / LU…DI`), Précédent /
  Suivant. Cells outside the filter are dimmed at 35 % opacity.
  `+ 1 semaine` extends the horizon by 7 days, repeatable.
- QR codes auto-generated by `cs_update` step 8 for every bookable
  zone (`cs_zone_<area>.png`) **and** every energy consumer in
  `cs_energy_consumers.json` (`cs_power_<entity>.png`). Files land
  in `/media/casasmooth/qrcodes/` so they appear in HA's Media
  Browser. All URLs use the bare UUID — host
  (`<uuid>.casasmooth.net`) and `?guid=` query parameter agree.

### Changed
- `cs_config._load_guid` strips the legacy `csuuid-` prefix at load
  time. `cfg.guid` is now the bare 36-char UUID everywhere; the
  cloud already accepts both forms.
- Booking session cookie is `Secure=True` when the request was HTTPS
  (frps adds `X-Forwarded-Proto`). Was always False, which some
  Android Chromium configs silently dropped on follow-up POSTs.
- Search view simplified — its tag chip + zone selector live in the
  parent, while date / time / weekday filters live inside the shared
  picker. The calendar time axis spans the union of matching zones'
  windows so columns stay stable when the user flips between zones.

### Fixed
- `POST /api/booking/bookings` returned 500 with
  `TypeError: can't compare offset-naive and offset-aware datetimes`.
  Pydantic v2 parses `…Z` ISO strings as timezone-aware; the route
  now normalizes to naive UTC via `_naive_utc()` before any comparison
  against `datetime.utcnow()`.
- Multi-slot reservation: Précédent / Suivant no longer wipe the list
  of pre-selections — they navigate only the latest slot and treat
  earlier ones as occupied. A click inside an already-selected range
  no longer removes the selection (use the row's `−` button). Changing
  the duration drops any selection that, post-change, would overlap
  an earlier one (insertion order wins).

## 2.0.35 - 2026-05-02

### Fixed
- Power router (`/api/power/*`) failed to mount on 2.0.34 because the
  addon image lacked `jinja2` (FastAPI's `Jinja2Templates` raised on
  import). Now baked alongside `sqlalchemy` in `Dockerfile.production`.
- Booking SPA built `https://...:28100/api/booking` for production —
  port 28100 is not exposed publicly via the casasmooth tunnel, so all
  fetches failed with "failed to fetch" once the user clicked Identify.
  Same-origin path on `*.casasmooth.net`, explicit `:28100` only on LAN
  direct.
- Booking magic-link emails now point at `/local/booking/index.html#/...`
  (HA blocks `/local/<dir>/` directory listings with 403, but serves
  named files).
- Booking magic-link email is now an HTML message with a clickable button
  (was plain text).

### Added
- Booking SPA logo (32px header) imported as a Vite asset.
- Booking SPA + Power templates pick up the canonical mobile theme tokens
  (`--surface`, `--on-surface`, `--card-background`, `--primary`, ...).
- nginx wildcard server caches hashed `/local/{mobile,booking}/assets/*`
  for 30 days — first hit goes through frps, subsequent hits served from
  the Azure VM (visible via `X-Cache-Status: HIT` header).

## 2.0.34 - 2026-05-02

### Fixed
- Addon boot was tripping the HA watchdog on slow / failing OpenRouter calls
  during help-page narrative generation, restart-looping the addon. `run.sh`
  now invokes `cs_update --skip-llm` at boot — the same outputs are filled in
  by the in-process background task in `app/api/server.py::_ui_docs_loop`
  once the API server is listening, so first-boot is fast and LLM work
  lands a few minutes later without blocking. (See
  `feedback_addon_boot_watchdog.md`.)

### Added
- `python3 -m app.commands.cs_update --skip-llm` direct flag (mirrors the
  `python3 -m app update --skip-llm` exposed in `cs_main.py`). Both gate the
  same three LLM steps in `cs_generator.run`: recommendations, context docs,
  and help page.
- `sqlalchemy>=2.0` baked into the addon image so the booking + power
  routers in `app/api/` import successfully and mount on `/api/booking/*`
  and `/api/power/*`.

## 2.0.33 - 2026-05-01

### Added
- Per-area `input_select.cs_<area>_lighting_source` and a 30-second
  `timer.cs_<area>_lighting_grace` per zone, forming a unified state
  machine for "who currently drives the lights in this area". Every
  lighting automation now declares its priority via the canonical
  table in `app/core/lighting_arbiter.py` (auto < manual < onoff =
  scene_memo < welcome < tv < scene_script < general < playback <
  fallback) and refuses to act when a higher-rank source already
  holds control.
- `general` mode wired into the existing all-on / all-off / smart-toggle
  buttons. Claims source on every area-with-lights for the duration of
  the action, then releases — blocked when any area is in playback or
  fallback.
- `fallback` kill switch: a global hourly automation that turns off any
  light that has been on longer than the new
  `input_number.cs_lighting_fallback_hours` slider (0 = disabled,
  default 0). Source claim isolates the kill from any active
  automation; runs in `parallel` so an unreachable device cannot
  strand the source.
- Scene 5-10 buttons now toggle: a second press of the same scene
  button stops the running animation; pressing a different 5-10 scene
  during an animation cleanly switches scripts. The dashboard button
  highlights while its script is running.

### Changed
- Standard / enhanced lighting automations now gate on
  `lighting_source == auto`. The old `lighting_timer == active` check
  is preserved alongside; the source check is what enforces the 30-s
  grace after a manual action.
- Scenes 5-10 are now framed as "scripted scenes" and the per-area
  scene 10 (formerly "Cercle de teinte") is repurposed as the
  circadian rhythm script — same 2700-6500 K / 30-100 % curve as the
  retired `auto_daylight_enabled` toggle, but driven by the regular
  scene-row UI instead of a standalone button.
- Welcome lighting and TV-scene-on now claim source so user actions
  cannot interrupt them silently. Welcome releases on its
  `lighting_timer` expiry; TV-scene-off releases when all media
  players become inactive.
- Playback mode toggles `source` on every area-with-lights — the
  whole house follows the global toggle in lockstep.
- Animation start (scene 5-10): the area's lights, bulbs, and
  wall-switches are always turned off before the script runs, even
  when transitioning between scenes. Fixes lit bulbs / switches that
  used to "leak through" an animation if they were on at start.
- Animation end (scene 5-10): RGB lights are reset to 3000 K at low
  brightness, then every area light is turned off. Lights no longer
  stay on in the script's last-frame color when an animation finishes.
  The dashboard "robot" toggle is restored to its pre-animation state
  (the per-scene cleanup already did this; the new safety net handles
  it too, important when `exceptions_enabled` is on and the per-scene
  cleanup is gated out).

### Fixed
- Per-day weekday exception schedule (`s5:07:01-07:04`, etc.) on
  enhanced-only-with-presence zones with no motion in the window. The
  override used to set `lighting_scene` and stop there; now it also
  presses the matching restore_scene button so the scene is actually
  applied without depending on a periodic auto tick.
- Animation script while-loop now also checks `lighting_source ==
  scene_script`, so a higher-priority mode (playback / general /
  fallback) supplanting mid-animation makes the script exit at the
  next iteration instead of running silently in the background.
- Scene 10 (circadian) iteration uses `wait_template` with a 60-s
  timeout instead of a flat `delay: 60s` — the script exits within
  ~100 ms of being supplanted instead of having to wait for the next
  natural cycle.
- `homeassistant.turn_off` calls in the new white+off cleanup,
  in the global force-off, and in fallback kill no longer pass a
  `transition` argument: the generic multi-domain service rejects
  the key when the target list mixes lights with switches, which was
  silently aborting the cleanup mid-sequence and leaving
  `lighting_source` stuck at `scene_script`.
- 50 % button now actually sets brightness to 50 %. The previous
  `light.turn_on` carried no `data` block, so dimmable lights came on
  at HA's default brightness (typically 100 % or last value). Same
  idempotent guard pattern as the 100 % button.
- 100 % automations are now generated only for areas with multiple
  lights (matching the dashboard button which is conditional on
  `has_multiple_lights`). Previously the automation was built
  unconditionally — single-light areas had a dead-code automation
  whose trigger entity did not exist.
- Stale `cs_<area>_auto_daylight_enabled` entity reference removed
  from standard / enhanced automations and from the `cs_home.py`
  generator. The entity is no longer produced; orphan entries in
  `.storage/core.entity_registry` are cosmetic and can be cleaned up
  via the HA UI.

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
