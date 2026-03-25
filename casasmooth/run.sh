#!/usr/bin/with-contenv bashio
# casasmooth Production Add-on Entry Point
# Runs compiled Python (.pyc) from /opt/casasmooth – source code stays in the image.
#
# Boot sequence:
#   1. On first install or version upgrade: sync static files → /config/casasmooth/
#      (Python code + app/data stay inside the image – never copied out)
#   2. Run install_deps.sh once to install HA add-ons (Mosquitto, SSH, Whisper, Piper, etc.)
#   3. Run cs_update to generate YAML / install HA files
#   4. Start MCP server in background, API server in foreground

set -e

# ---------------------------------------------------------------------------
# Configuration from add-on options
# ---------------------------------------------------------------------------
API_PORT=$(bashio::config 'api_port')
LOG_LEVEL=$(bashio::config 'log_level')

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
IMAGE_DIR="/opt/casasmooth"
CS_PATH="/config/casasmooth"
MCP_PORT=8003

# ---------------------------------------------------------------------------
# Version check
# ---------------------------------------------------------------------------
IMAGE_VERSION="$(cat ${IMAGE_DIR}/VERSION 2>/dev/null || echo '0.0.0')"
INSTALLED_VERSION="$(cat ${CS_PATH}/.addon_version 2>/dev/null || echo '')"

bashio::log.info "=========================================="
bashio::log.info "  casasmooth Add-on  v${IMAGE_VERSION}"
bashio::log.info "=========================================="
bashio::log.info "API Port : ${API_PORT}   MCP Port : ${MCP_PORT}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# ---------------------------------------------------------------------------
# First install or version upgrade: sync static files
# ---------------------------------------------------------------------------
if [ "${IMAGE_VERSION}" != "${INSTALLED_VERSION}" ]; then
    if [ -z "${INSTALLED_VERSION}" ]; then
        bashio::log.info "First install detected – syncing files to ${CS_PATH}..."
    else
        bashio::log.info "Upgrade ${INSTALLED_VERSION} → ${IMAGE_VERSION} – syncing files..."
    fi

    mkdir -p "${CS_PATH}"

    # Sync static directories (overwrite on upgrade, skip nothing)
    for dir in resources custom_components images medias commands lib; do
        if [ -d "${IMAGE_DIR}/${dir}" ]; then
            bashio::log.info "  Syncing ${dir}/..."
            mkdir -p "${CS_PATH}/${dir}"
            cp -rf "${IMAGE_DIR}/${dir}/." "${CS_PATH}/${dir}/"
        fi
    done

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
if [ -d "${CS_PATH}/commands" ]; then
    chmod +x "${CS_PATH}/commands/"*.sh 2>/dev/null || true
fi
if [ -d "${CS_PATH}/lib" ]; then
    chmod +x "${CS_PATH}/lib/"*.sh 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Export environment
# ---------------------------------------------------------------------------
export CASASMOOTH_PATH="${CS_PATH}"
export CS_APP_DATA="${IMAGE_DIR}/app/data"
export CS_TEXTS="${IMAGE_DIR}/texts"
export PYTHONPATH="${IMAGE_DIR}"
export LOG_LEVEL="${LOG_LEVEL}"

bashio::log.info "SUPERVISOR_TOKEN: $([ -n "${SUPERVISOR_TOKEN}" ] && echo 'Available' || echo 'NOT available – API calls will fail')"

# ---------------------------------------------------------------------------
# Run cs_update (first boot OR every boot)
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
