# Changelog

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
