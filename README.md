## Bootc CentOS Workstation

An atomic workstation built on the CentOS Stream 10 `bootc` image.

### Currently building image:

### `bootc-centos:latest`

- Very minimal workstation installation with KDE Plasma
- Tailored for specific hardware and personal use; most firmware and many packages removed
- bootc-native workflow using `bootc-base-imagectl` for image rechunking
- Some pre-configured system-wide defaults
- Justfile and `jmain` alias for initial configuration and basic system maintenance
- Modular build files for easy image customization

#### Legacy branches:

#### `bootc-centos:gnome`

- Trimmed "Workstation" installation with GNOME
  - Minimal font and language pack set
  - Printing support removed
  - Selected packages excluded/removed to reduce image size and favor Flatpak alternatives
- Small set of essential tools and utilities

#### `bootc-centos:kde`

- Customized "Workstation" installation with KDE Plasma
  - Trimmed KDE Plasma desktop environment
  - Minimal font and language pack set
  - Printing support removed
  - Selected packages excluded/removed to reduce image size and favor Flatpak alternatives
- Small set of essential tools and utilities

&nbsp;<br>

### These images are intended solely for personal use
