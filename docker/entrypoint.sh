#!/bin/sh
# Container entrypoint: runs aster-sysinfo (sensor collection) in the background
# and asterctl (panel rendering) in the foreground.
#
# Any argument bypasses the panel loop and is passed straight to asterctl,
# e.g.: docker compose run --rm asterctl --off
set -eu

if [ $# -gt 0 ]; then
    exec /app/asterctl "$@"
fi

: "${ASTERCTL_DEVICE:=/dev/ttyUSB0}"
: "${ASTERCTL_CONFIG:=monitor.json}"
: "${ASTERCTL_SIMULATE:=0}"
: "${NET_INTERFACE:=}"
: "${SENSOR_REFRESH:=3}"
: "${DISK_REFRESH:=60}"
: "${SMARTCTL:=1}"
: "${LCD_OFF_ON_STOP:=1}"

SENSOR_DIR=/tmp/sensors
SENSOR_TMP=/tmp/sensors-tmp
mkdir -p "$SENSOR_DIR" "$SENSOR_TMP"

# Auto-detect the interface holding the default route if none is configured.
# Requires host network mode, otherwise the container only sees its own veth.
if [ -z "$NET_INTERFACE" ]; then
    NET_INTERFACE=$(awk '$2 == "00000000" { print $1; exit }' /proc/net/route)
fi
echo "Sensor mapping network interface: ${NET_INTERFACE:-<none detected>}"

# generate the sensor mapping with the actual network interface name
sed "s/@NET_IF@/${NET_INTERFACE}/g" /app/cfg/sensor-mapping/docker.tmpl \
    > /app/cfg/sensor-mapping/docker.cfg

SYSINFO_ARGS="--refresh $SENSOR_REFRESH --out $SENSOR_DIR/aster-sysinfo.txt --temp-dir $SENSOR_TMP"
if [ "$DISK_REFRESH" -gt 0 ] 2>/dev/null; then
    SYSINFO_ARGS="$SYSINFO_ARGS --disk-refresh $DISK_REFRESH"
    if [ "$SMARTCTL" = "1" ]; then
        SYSINFO_ARGS="$SYSINFO_ARGS --smartctl"
    fi
fi

echo "Starting aster-sysinfo $SYSINFO_ARGS"
# shellcheck disable=SC2086
/app/aster-sysinfo $SYSINFO_ARGS &
SYSINFO_PID=$!

# wait for the first sensor values before rendering panels
i=0
while [ ! -f "$SENSOR_DIR/aster-sysinfo.txt" ] && [ $i -lt 30 ]; do
    i=$((i + 1))
    sleep 1
done

if [ "$ASTERCTL_SIMULATE" = "1" ]; then
    DEVICE_ARGS="--simulate"
else
    DEVICE_ARGS="--device $ASTERCTL_DEVICE"
fi

echo "Starting asterctl $DEVICE_ARGS with config $ASTERCTL_CONFIG"
# shellcheck disable=SC2086
/app/asterctl $DEVICE_ARGS \
    --config "$ASTERCTL_CONFIG" \
    --config-dir /app/cfg \
    --font-dir /app/fonts \
    --sensor-path "$SENSOR_DIR" \
    --sensor-mapping sensor-mapping/docker.cfg \
    ${ASTERCTL_EXTRA_ARGS:-} &
ASTERCTL_PID=$!

shutdown() {
    kill "$ASTERCTL_PID" "$SYSINFO_PID" 2>/dev/null || true
    wait "$ASTERCTL_PID" 2>/dev/null || true
    if [ "$LCD_OFF_ON_STOP" = "1" ] && [ "$ASTERCTL_SIMULATE" != "1" ]; then
        echo "Switching LCD off"
        /app/asterctl --device "$ASTERCTL_DEVICE" --off || true
    fi
    exit 0
}
trap shutdown TERM INT

wait "$ASTERCTL_PID" || true
# asterctl exited on its own: stop the sensor collector and let the
# container restart policy handle recovery
kill "$SYSINFO_PID" 2>/dev/null || true
exit 1
