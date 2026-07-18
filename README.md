# AOOSTAR WTR MAX / GEM12+ PRO Screen Control

Reverse engineering the [AOOSTAR WTR MAX](https://aoostar.com/products/aoostar-wtr-max-amd-r7-pro-8845hs-11-bays-mini-pc)
display protocol, with a proof-of-concept application written in Rust.  
It has only been tested on the WTR MAX, but should also support the GEM12+ PRO device.

> This repository is an independent continuation of
> [zehnm/aoostar-rs](https://github.com/zehnm/aoostar-rs). The protocol reverse
> engineering and the original implementation are the work of Markus Zehnder —
> all credit for the foundations goes there. This fork adds Docker support and
> continues maintenance.

Check out the **[User Guide](https://malouf-dev.github.io/aoostar-rs)** for a list of features and installation and usage information.

## Features

- Control the AOOSTAR WTR MAX and GEM12+ PRO second screen from Linux.
- [Run everything in Docker](docs/docker.md) with one `docker compose up` — stock panels with live host sensor data.
- Switch the display on or off.
    - Also possible with standard [Linux shell commands](docs/shell_commands.md).
    - [Linux systemd Service](docs/linux/README.md) to automatically switch off the LCD at boot up.
- Display images (with automatic scaling and partial update support).
- Render dynamic sensor panels defined from the AOOSTAR-X software.
    - Update sensor values from simple text files.
    - Rotate through multiple panels in a defined interval.
- USB device/serial port selection.

## Disclaimer

> I take no responsibility for the use of this software.  
> There is no official documentation available;
> all display control commands have been reverse engineered from the original AOOSTAR-X software.

Even though this software works fine **for me**, I cannot guarantee that it is risk-free:

- It may or may not work.
- It could crash the display firmware, requiring a power cycle.
- It could even brick the display firmware.
- You have been warned!

The risk remains until the manufacturer provides official documentation, and the protocol can be reviewed.
Note: Multiple attempts to contact the manufacturer for documentation have received no response.

With that out of the way, on to the fun stuff!

- Browse the source code or read the [User Guide](https://malouf-dev.github.io/aoostar-rs)
- Run it with [Docker](docs/docker.md) (recommended), or see [releases](https://github.com/malouf-dev/aoostar-rs/releases) for binary Linux x64 releases.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please note that this software is currently in its initial development and will have major changes until the mentioned
goals above are reached!

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT License ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
