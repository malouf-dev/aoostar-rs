# Docker

Runs `aster-sysinfo` (live sensor collection) and `asterctl` (LCD panel rendering)
together in one container, showing the stock AOOSTAR-X panels with live host data.
This is the easiest way to run the screen software on a NAS: no Rust toolchain on
the host, automatic restart on boot, and one command to update.

Tested target: Ubuntu Server 24.04 on the AOOSTAR WTR MAX with Docker Engine.

## Quick start

On the host the LCD is plugged into:

```shell
git clone https://github.com/malouf-dev/aoostar-rs.git
cd aoostar-rs
docker compose up -d --build
```

That's it. The image builds from source (the first build takes a few minutes),
the container starts both tools and the LCD begins cycling the stock panels.

Check the logs:

```shell
docker compose logs -f
```

Stop (also switches the LCD off):

```shell
docker compose down
```

## Finding the LCD serial port

The default device is `/dev/ttyUSB0`. If that is not the right port, find it with:

```shell
ls -l /dev/serial/by-id/
```

and set `ASTERCTL_DEVICE` in `docker-compose.yml` to the matching
`/dev/serial/by-id/...` path — those names are stable across reboots.

## Configuration

All settings are environment variables in `docker-compose.yml`:

| Variable | Default | Description |
|---|---|---|
| `ASTERCTL_DEVICE` | `/dev/ttyUSB0` | LCD serial port |
| `ASTERCTL_CONFIG` | `monitor.json` | Panel configuration file (in `/app/cfg`) |
| `NET_INTERFACE` | auto | Interface for the network panel sensors. Auto-detected from the default route if unset. |
| `SENSOR_REFRESH` | `3` | Sensor refresh interval in seconds |
| `DISK_REFRESH` | `60` | Per-disk usage/temperature refresh interval in seconds, `0` disables |
| `SMARTCTL` | `1` | Drive temperatures via smartctl |
| `LCD_OFF_ON_STOP` | `1` | Switch the LCD off when the container stops |
| `ASTERCTL_SIMULATE` | `0` | Render without hardware (testing) |
| `ASTERCTL_EXTRA_ARGS` | | Extra arguments appended to `asterctl` |

One-off commands go straight to `asterctl`, for example switching the display off:

```shell
docker compose run --rm asterctl --off
```

## Why host network, privileged mode and the `/` mount?

The point of the container is to show the *host's* live data, so a few
isolation walls need doors in them:

- `network_mode: host` — otherwise the container only sees its own virtual
  interface and the network speed / IP sensors would be meaningless.
- `privileged: true` — gives the container the LCD serial port, and lets
  `smartctl` read drive temperatures from `/dev/sd*` and `/dev/nvme*`.
- `/:/host:ro,rslave` — makes the host's mounted filesystems visible
  (read-only) so disk usage reflects the real mounts, not the container's.

CPU usage, temperatures, RAM and uptime need no special access: Linux exposes
host-wide values in `/proc` and `/sys` even inside a container.

### Locked-down alternative

If you prefer not to run privileged, replace `privileged: true` with explicit
device grants:

```yaml
    cap_add:
      - SYS_RAWIO        # smartctl SMART commands
      - SYS_ADMIN        # smartctl on NVMe
    devices:
      - /dev/ttyUSB0     # the LCD
      - /dev/nvme0       # repeat for each drive smartctl should read
      - /dev/sda
```

Drive device paths can change when hardware changes; privileged mode is the
low-maintenance option on a box that only runs your own containers.

## Sensor mapping

The stock panels look up sensor labels like `cpu_temperature` or
`storage_hdd[0]['used']`. The file `docker/sensor-mapping/docker.tmpl` maps
those to the values `aster-sysinfo` collects, and the entrypoint substitutes
the network interface name at startup. To customize, edit the template and
rebuild, or mount your own file over `/app/cfg/sensor-mapping/docker.tmpl`.

See [Sensor Value Provider](sensor/provider/README.md) for the available sensors.

## Verifying without the LCD

Set `ASTERCTL_SIMULATE: "1"` and `ASTERCTL_EXTRA_ARGS: --save` in the
environment: panels are rendered to `/app/out` inside the container instead of
the display. Copy them out with `docker cp asterctl:/app/out .` and view the
PNG files.

## Troubleshooting

If a panel field stays blank, look at what the sensor collector actually
provides:

```shell
docker compose exec asterctl cat /tmp/sensors/aster-sysinfo.txt
```

If the value exists under a different label, adjust
`docker/sensor-mapping/docker.tmpl` accordingly and rebuild.
