# AOOSTAR WTR MAX Screen Control Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

_Changes in the next release_

## v0.3.0 - 2026-07-18

First release of this independent continuation of [zehnm/aoostar-rs](https://github.com/zehnm/aoostar-rs).

### Added
- Docker support: multi-stage Dockerfile, entrypoint running `aster-sysinfo` + `asterctl` together,
  `docker-compose.yml` with host data access, and a Docker sensor mapping with network interface auto-detection.
- aster-sysinfo: `gpu_usage_percent` sensor from the drm sysfs interface (amdgpu `gpu_busy_percent`).

### Fixed
- aster-sysinfo: run smartctl directly without sudo when running as root (container use case).
- aster-sysinfo: `storage_ssd/hdd[x]_usage_percent` no longer flaps between two different data
  sources when the individual disk refresh logic is enabled.

## v0.2.0 - 2025-08-31
### Fixed
- Misplaced text sensors in custom panels ([#11](https://github.com/zehnm/aoostar-rs/issues/11)).
- Wrong start position for circular progress (fan) sensor using a counter-clockwise direction ([#12](https://github.com/zehnm/aoostar-rs/issues/12)).
- aster-sysinfo tool: make sensor file world-readable, create all parent directories.

### Added
- Simple sensor panel with a file-based data source ([#6](https://github.com/zehnm/aoostar-rs/issues/6)). 
- Initial support for fan-, progress-, & pointer-sensors ([#8](https://github.com/zehnm/aoostar-rs/pull/8)).
- Use [mdBook](https://rust-lang.github.io/mdBook/) for documentation and publish user guide to GitHub pages ([#10](https://github.com/zehnm/aoostar-rs/pull/10)).
- Initial `aster-sysinfo` tool for providing sensor values in a text file for `asterctl`.

### Changed
- Project structure using a Cargo workspace.

---

## v0.1.0 - 2025-08-02
### Added
- Initial `asterctl` tool release for controlling the LCD: on, off, display an image.
- systemd service file to switch off LCD on system start.
- Demo mode.
