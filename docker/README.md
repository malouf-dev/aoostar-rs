# Running in Docker

Runs `aster-sysinfo` (live sensor collection) and `asterctl` (LCD panel rendering)
together in one container, showing the stock AOOSTAR-X panels with live host data.

Quick start, from the repository root on the host the LCD is plugged into:

```shell
docker compose up -d --build
```

Full instructions — configuration reference, finding the serial port, security
notes, sensor mapping and troubleshooting — are in the
**[Docker chapter of the User Guide](https://malouf-dev.github.io/aoostar-rs/docker.html)**
(source: [docs/docker.md](../docs/docker.md)).
