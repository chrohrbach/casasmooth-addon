#!/usr/bin/with-contenv bashio
# casasmooth Add-on Entry Point
# This file is baked into the Docker image at /run.sh.
# It mirrors casasmooth-addon/casasmooth/run.sh – keep them in sync.
#
# Two runtime modes controlled by the "dev_mount" add-on option:
#   • dev_mount: false (PROD)  — Python code runs from /opt/casasmooth/app
#                                (baked .pyc in the image).  This is what
#                                clients run and what stable releases test.
#   • dev_mount: true  (DEV)   — /opt/casasmooth/app is replaced by a symlink
#                                to /config/casasmooth/app (user-editable).
#                                Same run.sh, same install_deps, same boot
#                                sequence as prod — only the source differs.
#
# Boot sequence (identical in both modes):
#   1. Resolve dev_mount → swap app symlink, export CASASMOOTH_MODE.
#   2. On first install or version upgrade: sync static files to /config/casasmooth/.
#      Skipped in dev_mount mode (developer owns /config/casasmooth/).
#   3. Run install_deps.sh once to install HA add-ons (Mosquitto, SSH, …).
#   4. Run cs_update to generate YAML / install HA files.
#   5. Start MCP server in background, API server in foreground.

set -e

# ---------------------------------------------------------------------------
# Configuration from add-on options
# ---------------------------------------------------------------------------
API_PORT=$(bashio::config 'api_port')
LOG_LEVEL=$(bashio::config 'log_level')
DEV_MOUNT=$(bashio::config 'dev_mount' 'false')

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
IMAGE_DIR="/opt/casasmooth"
CS_PATH="/config/casasmooth"
MCP_PORT=8003

# ---------------------------------------------------------------------------
# Version check (based on image /opt/casasmooth/VERSION)
# ---------------------------------------------------------------------------
IMAGE_VERSION="$(cat ${IMAGE_DIR}/VERSION 2>/dev/null || echo '0.0.0')"
INSTALLED_VERSION="$(cat ${CS_PATH}/.addon_version 2>/dev/null || echo '')"

bashio::log.info "=========================================="
bashio::log.info "  casasmooth Add-on  v${IMAGE_VERSION}"
bashio::log.info "=========================================="
bashio::log.info "API Port : ${API_PORT}   MCP Port : ${MCP_PORT}"
bashio::log.info "Log Level: ${LOG_LEVEL}"
bashio::log.info "Dev mount: ${DEV_MOUNT}"

# ---------------------------------------------------------------------------
# Resolve dev_mount — swap /opt/casasmooth/app between baked and mounted.
#
# State machine (idempotent across restarts):
#   baked       : /opt/casasmooth/app is a real directory (.pyc from image)
#   mounted     : /opt/casasmooth/app is a symlink → /config/casasmooth/app
#   app.baked/  : backup of the baked directory (created on first dev_mount)
# ---------------------------------------------------------------------------
if [ "${DEV_MOUNT}" = "true" ] && [ -d "${CS_PATH}/app" ]; then
    bashio::log.info "DEV MODE: using /config/casasmooth/app (editable source)"
    export CASASMOOTH_MODE="development"
    # First-time dev_mount: preserve baked copy so we can restore later.
    if [ ! -L "${IMAGE_DIR}/app" ] && [ ! -d "${IMAGE_DIR}/app.baked" ]; then
        mv "${IMAGE_DIR}/app" "${IMAGE_DIR}/app.baked"
    fi
    rm -rf "${IMAGE_DIR}/app"
    ln -sfn "${CS_PATH}/app" "${IMAGE_DIR}/app"
else
    if [ "${DEV_MOUNT}" = "true" ]; then
        bashio::log.warning "dev_mount requested but ${CS_PATH}/app missing – falling back to baked code"
    else
        bashio::log.info "PROD MODE: using /opt/casasmooth/app (baked)"
    fi
    export CASASMOOTH_MODE="production"
    # Restore baked directory if we were previously in dev mode.
    if [ -L "${IMAGE_DIR}/app" ]; then
        rm -f "${IMAGE_DIR}/app"
    fi
    if [ ! -d "${IMAGE_DIR}/app" ] && [ -d "${IMAGE_DIR}/app.baked" ]; then
        mv "${IMAGE_DIR}/app.baked" "${IMAGE_DIR}/app"
    fi
fi

# ---------------------------------------------------------------------------
# First install or version upgrade: sync static files (PROD only).
# In DEV mode the developer manages /config/casasmooth/ directly via git/rsync,
# so syncing from the image would overwrite their working tree.
# ---------------------------------------------------------------------------
if [ "${CASASMOOTH_MODE}" = "production" ] && [ "${IMAGE_VERSION}" != "${INSTALLED_VERSION}" ]; then
    if [ -z "${INSTALLED_VERSION}" ]; then
        bashio::log.info "First install detected – syncing files to ${CS_PATH}..."
    else
        bashio::log.info "Upgrade ${INSTALLED_VERSION} → ${IMAGE_VERSION} – syncing files..."
        # Remove retired top-level directories from /config/casasmooth/.
        # This ONLY runs in PROD mode on version upgrade — dev machines keep
        # their /config/casasmooth/ git working tree untouched. Extend this
        # list conservatively: only add directories that (a) were previously
        # part of the addon image and (b) are confirmed no longer referenced
        # by any code path. Every entry is a retired feature, not a guess.
        #
        # Retired:
        #   commands/  — 2025 legacy bash scripts (replaced by app/commands/)
        #   lib/       — 2025 legacy bash libraries (replaced by app/core/)
        #   addon-dev/ — 2026-04 dev addon manifest (replaced by dev_mount option)
        #   cs_install.sh — 2025 legacy installer (replaced by HA Add-on Store)
        for legacy in commands lib addon-dev; do
            if [ -d "${CS_PATH}/${legacy}" ]; then
                bashio::log.info "  Removing retired ${legacy}/ directory from ${CS_PATH}..."
                rm -rf "${CS_PATH}/${legacy}"
            fi
        done
        for legacy_file in cs_install.sh cs_update.sh; do
            if [ -f "${CS_PATH}/${legacy_file}" ]; then
                bashio::log.info "  Removing retired ${legacy_file} from ${CS_PATH}..."
                rm -f "${CS_PATH}/${legacy_file}"
            fi
        done
    fi

    mkdir -p "${CS_PATH}"

    # Sync static directories (overwrite on upgrade)
    for dir in resources custom_components images medias; do
        if [ -d "${IMAGE_DIR}/${dir}" ]; then
            bashio::log.info "  Syncing ${dir}/..."
            mkdir -p "${CS_PATH}/${dir}"
            cp -rf "${IMAGE_DIR}/${dir}/." "${CS_PATH}/${dir}/"
        fi
    done

    # Sync the host-side shell helpers used by HA shell_command.
    if [ -d "${IMAGE_DIR}/app/tools" ]; then
        bashio::log.info "  Syncing app/tools shell helpers..."
        mkdir -p "${CS_PATH}/app/tools"
        find "${IMAGE_DIR}/app/tools" -maxdepth 1 -type f -name '*.sh' -exec cp -f {} "${CS_PATH}/app/tools/" \;
    fi

    # Sync mobile PWA if present
    if [ -d "${IMAGE_DIR}/www" ]; then
        bashio::log.info "  Syncing www/ (mobile PWA)..."
        mkdir -p "${CS_PATH}/www"
        cp -rf "${IMAGE_DIR}/www/." "${CS_PATH}/www/"
    fi

    # Stamp installed version
    echo "${IMAGE_VERSION}" > "${CS_PATH}/.addon_version"
    # Clear addon restart marker so cs_update will restart once for the new version
    rm -f "${CS_PATH}/cache/cs_addon_restart_done.txt"
    bashio::log.info "Files synced to ${CS_PATH}"
fi

# ---------------------------------------------------------------------------
# Install required Home Assistant add-ons (once per machine)
# ---------------------------------------------------------------------------
DEPS_STAMP="${CS_PATH}/.deps_installed"
if [ ! -f "${DEPS_STAMP}" ]; then
    bashio::log.info "Running dependency installer..."
    if "${IMAGE_DIR}/install_deps.sh"; then
        touch "${DEPS_STAMP}"
        bashio::log.info "Dependencies installed."
    else
        bashio::log.warning "Dependency installation had errors – check logs."
    fi
fi

# ---------------------------------------------------------------------------
# Make shell scripts executable (required for HA shell_command)
# ---------------------------------------------------------------------------
if [ -d "${CS_PATH}/app/tools" ]; then
    chmod +x "${CS_PATH}/app/tools/"*.sh 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Export environment
# ---------------------------------------------------------------------------
export CASASMOOTH_PATH="${CS_PATH}"
# CS_APP_DATA / texts/ live inside the image even in dev mode (data files,
# not editable source). If the developer needs to iterate on them they can
# also override via cs_deploy.
export CS_APP_DATA="${IMAGE_DIR}/app/data"
export CS_TEXTS="${IMAGE_DIR}/texts"
export PYTHONPATH="${IMAGE_DIR}"
export LOG_LEVEL="${LOG_LEVEL}"

bashio::log.info "SUPERVISOR_TOKEN: $([ -n "${SUPERVISOR_TOKEN}" ] && echo 'Available' || echo 'NOT available – API calls will fail')"

# ---------------------------------------------------------------------------
# First-real-boot identity individualization.
#
# Must run BEFORE cs_update below: cs_update's setup_directories() loads the
# guid and sends the first outbound cloud call (POST /api/secrets) within a
# few lines of each other, and the tunnel service (spawned later by the API
# server) will skip cloud provisioning entirely and silently reuse a cached
# identity if /data/tunnel/frpc.toml already exists (tunnel_service.py:624).
# Both are too late/too dangerous to gate after the fact — this has to be
# the very first thing that can touch identity state on this boot.
#
# Why this exists: casasmooth's GUID *is* Home Assistant's own instance uuid
# (.storage/core.uuid, ARCHITECTURE.md §12) — a pure software value with no
# hardware binding, persisted forever once generated. Teleia ships SD cards
# with HA + csadmin + this addon already installed (a genuinely blank golden
# image would be safer but isn't acceptable for prep-time reasons), so a
# naively cloned card would silently duplicate a live system's identity —
# exactly the incident this guards against.
#
# The marker (locals/cs_individualized) must be ABSENT from the golden image
# itself — deleted as the last step of image preparation (see the
# "Prepare for Cloning" dashboard button in the casasmooth repo,
# app/services/onboarding_service.py::prepare_for_cloning(), which also
# deletes the same four paths below). Whichever happens first — this boot
# hook individualizing fresh, or a deliberate restore action adopting an
# existing identity from a backup — sets the marker; the other becomes a
# no-op. A restore action always writes the marker itself and may run AFTER
# this hook already individualized fresh on first boot — that's expected,
# restore deliberately overwrites whatever identity this hook assigned.
#
# Deletion order matters for crash-safety: the tunnel/services caches (the
# files that let the tunnel service skip cloud provisioning and silently
# resume a stale identity) are cleared BEFORE core.uuid, and the marker is
# written LAST of all. A power-loss at any point during this leaves the
# system still looking "not yet individualized" on the next boot — never a
# stale-but-internally-consistent identity. Deleting an already-deleted file
# is a no-op, so re-running this whole block on retry is always safe.
# ---------------------------------------------------------------------------
INDIVIDUALIZED_MARKER="${CS_PATH}/locals/cs_individualized"
if [ ! -f "${INDIVIDUALIZED_MARKER}" ]; then
    bashio::log.info "First real boot on this hardware — individualizing identity..."
    rm -f "${CS_PATH}/locals/cs_tunnel_token" 2>/dev/null || true
    rm -f "/data/tunnel/frpc.toml" 2>/dev/null || true
    rm -f "${CS_PATH}/locals/cs_services.json" 2>/dev/null || true
    rm -f "/config/.storage/core.uuid" 2>/dev/null || true
    mkdir -p "${CS_PATH}/locals"
    touch "${INDIVIDUALIZED_MARKER}"
    bashio::log.info "Identity wiped — HA will generate a fresh core.uuid, casasmooth will re-provision a fresh tunnel token, on this boot."
fi

# ---------------------------------------------------------------------------
# Run cs_update (first boot OR version upgrade)
# On first boot this generates all YAML, copies resources → /config/www/,
# copies custom_components, writes configuration.yaml includes, etc.
# On subsequent boots it is a fast no-op if nothing changed.
# ---------------------------------------------------------------------------
bashio::log.info "Running casasmooth update (cs_update)..."
python3 -m app.commands.cs_update \
    --log --verbose \
    && bashio::log.info "cs_update completed successfully." \
    || bashio::log.warning "cs_update finished with warnings – check logs."

# ---------------------------------------------------------------------------
# Start MCP server in background
# ---------------------------------------------------------------------------
bashio::log.info "Starting MCP server on port ${MCP_PORT}..."
python3 -m app.mcp.server --transport sse --host 0.0.0.0 --port "${MCP_PORT}" &
MCP_PID=$!
bashio::log.info "MCP server started (PID: ${MCP_PID})"

# ---------------------------------------------------------------------------
# Start API server in foreground (process supervisor will restart on crash)
# ---------------------------------------------------------------------------
bashio::log.info "Starting casasmooth API server on port ${API_PORT}..."
bashio::log.info "=========================================="
exec python3 -m app.api \
    --host 0.0.0.0 \
    --port "${API_PORT}" \
    --log-level "${LOG_LEVEL}"
