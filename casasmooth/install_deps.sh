#!/usr/bin/with-contenv bash
# install_deps.sh – install required Home Assistant add-ons via the Supervisor API.
# This file is baked into the Docker image at /opt/casasmooth/install_deps.sh.
# It mirrors casasmooth-addon/casasmooth/install_deps.sh – keep them in sync.
#
# Called once by run.sh when /config/casasmooth/.deps_installed does not exist.
# Requires SUPERVISOR_TOKEN (injected automatically when hassio_api: true).
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

addon_state() {
    local slug="$1"
    local result
    result=$(curl -sf -H "${AUTH_HEADER}" \
        "${SUPERVISOR_API}/addons/${slug}/info" 2>/dev/null \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('state','unknown'))" 2>/dev/null \
        || echo "unknown")
    echo "$result"
}

wait_for_addon_state() {
    local slug="$1"
    local expected_csv="$2"
    local timeout_seconds="$3"
    local waited=0
    local state

    while [ "$waited" -lt "$timeout_seconds" ]; do
        state=$(addon_state "${slug}")
        case ",${expected_csv}," in
            *",${state},"*)
                echo "${state}"
                return 0
                ;;
        esac
        sleep 2
        waited=$((waited + 2))
    done

    state=$(addon_state "${slug}")
    echo "${state}"
    return 1
}

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
        state=$(wait_for_addon_state "${slug}" "installing,stopped,started" 60) || true
        if [ "${state}" = "unknown" ] || [ "${state}" = "none" ] || [ "${state}" = "error" ]; then
            log_err "${name} did not become available after install attempt (state: ${state})."
            return 1
        fi
        log_ok "${name} available after install attempt – state: ${state}"
    else
        log_err "${name} install returned HTTP ${http_code}."
        return 1
    fi
}

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
        if ! curl -sf -X POST \
            -H "${AUTH_HEADER}" \
            "${SUPERVISOR_API}/addons/${slug}/start" >/dev/null 2>&1; then
            log_err "Could not start ${name}."
            return 1
        fi

        state=$(wait_for_addon_state "${slug}" "started" 60) || true
        if [ "${state}" != "started" ]; then
            log_err "${name} did not reach started state (state: ${state})."
            return 1
        fi

        log_ok "${name} started."
        return 0
    fi

    log_err "${name} is in unexpected state: ${state}"
    return 1
}

# ---------------------------------------------------------------------------
# Check token
# ---------------------------------------------------------------------------
if [ -z "${SUPERVISOR_TOKEN}" ]; then
    log_err "SUPERVISOR_TOKEN is not set – cannot contact the Supervisor API."
    exit 1
fi

log "Starting dependency installation..."

# ---------------------------------------------------------------------------
# 1. Mosquitto MQTT Broker
# ---------------------------------------------------------------------------
install_addon "core_mosquitto" "Mosquitto broker"
start_addon "core_mosquitto" "Mosquitto broker"

# ---------------------------------------------------------------------------
# 2. OpenSSH
# ---------------------------------------------------------------------------
install_addon "core_ssh" "OpenSSH"
log "OpenSSH installed – configure SSH keys in the add-on options before starting."

# ---------------------------------------------------------------------------
# 3. Shared directories
# ---------------------------------------------------------------------------
mkdir -p /share/mosquitto
log_ok "Created /share/mosquitto bridge config directory."

log_ok "Dependency installation complete."
