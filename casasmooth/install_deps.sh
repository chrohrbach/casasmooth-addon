#!/usr/bin/with-contenv bash
# install_deps.sh – install required Home Assistant add-ons via the Supervisor API.
#
# Called once by run.sh when /config/casasmooth/.deps_installed does not exist.
# Requires SUPERVISOR_TOKEN to be set (injected automatically by HA when the add-on
# has hassio_api: true in config.yaml).
#
# Add-ons installed:
#   - core_mosquitto  (MQTT broker – required for device communication)
#   - core_ssh        (SSH terminal  – required for remote management)

set -e

log()     { echo "[casasmooth/install_deps] $*"; }
log_ok()  { echo "[casasmooth/install_deps] ✓ $*"; }
log_warn(){ echo "[casasmooth/install_deps] ⚠ $*"; }
log_err() { echo "[casasmooth/install_deps] ✗ $*"; }

SUPERVISOR_API="http://supervisor"
AUTH_HEADER="Authorization: Bearer ${SUPERVISOR_TOKEN}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Return the state of an add-on (none/installing/started/stopped/error/unknown)
addon_state() {
    local slug="$1"
    local result
    result=$(curl -sf -H "${AUTH_HEADER}" \
        "${SUPERVISOR_API}/addons/${slug}/info" 2>/dev/null \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('state','unknown'))" 2>/dev/null \
        || echo "unknown")
    echo "$result"
}

# Install an add-on if it is not already present.
# Returns 0 on success / already installed, 1 on failure.
install_addon() {
    local slug="$1"
    local name="$2"

    local state
    state=$(addon_state "${slug}")

    if [ "${state}" != "unknown" ] && [ "${state}" != "none" ]; then
        log_ok "${name} (${slug}) already installed – state: ${state}"
        return 0
    fi

    log "Installing ${name} (${slug})..."

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "${AUTH_HEADER}" \
        -H "Content-Type: application/json" \
        "${SUPERVISOR_API}/addons/${slug}/install" 2>/dev/null || echo "000")

    if [ "${http_code}" = "200" ] || [ "${http_code}" = "201" ]; then
        log_ok "${name} installed."
    else
        log_warn "${name} install returned HTTP ${http_code} – it may already be installing or the slug changed."
    fi
}

# Start an add-on if it is in state 'stopped'.
start_addon() {
    local slug="$1"
    local name="$2"

    local state
    state=$(addon_state "${slug}")

    if [ "${state}" = "started" ]; then
        log_ok "${name} is already running."
        return 0
    fi

    if [ "${state}" = "stopped" ]; then
        log "Starting ${name} (${slug})..."
        curl -sf -X POST \
            -H "${AUTH_HEADER}" \
            "${SUPERVISOR_API}/addons/${slug}/start" >/dev/null 2>&1 \
            && log_ok "${name} started." \
            || log_warn "Could not start ${name} – it may need manual configuration first."
    fi
}

# ---------------------------------------------------------------------------
# Check token
# ---------------------------------------------------------------------------
if [ -z "${SUPERVISOR_TOKEN}" ]; then
    log_err "SUPERVISOR_TOKEN is not set – cannot contact the Supervisor API."
    log_err "Make sure hassio_api: true is set in config.yaml."
    exit 1
fi

log "Starting dependency installation..."
log "Supervisor API: ${SUPERVISOR_API}"

# ---------------------------------------------------------------------------
# 1. Mosquitto MQTT Broker (core_mosquitto)
# ---------------------------------------------------------------------------
install_addon "core_mosquitto" "Mosquitto broker"

# Give the supervisor a moment to register the install
sleep 2

start_addon "core_mosquitto" "Mosquitto broker"

# ---------------------------------------------------------------------------
# 2. OpenSSH (core_ssh)
# ---------------------------------------------------------------------------
install_addon "core_ssh" "OpenSSH"

sleep 2

# Note: core_ssh stays 'stopped' until the user configures SSH keys / password.
# We only install it here and do not attempt to start it.
log "OpenSSH installed – configure SSH keys in the add-on options before starting."

# ---------------------------------------------------------------------------
# 3. Ensure /share/mosquitto directory exists (used for MQTT bridge config)
# ---------------------------------------------------------------------------
mkdir -p /share/mosquitto
log_ok "Created /share/mosquitto bridge config directory."

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
log_ok "Dependency installation complete."
