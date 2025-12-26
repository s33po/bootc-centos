## Bootc CentOS Workstation

An atomic workstation built on the CentOS Stream 10 `bootc` image.

### Currently Building Images:

### `bootc-centos:latest`

- Trimmed "Workstation" installation
- Small set of basic tools and utilities
- Basic support for document and image thumbnailing
- Some pre-configured system-wide settings
- Justfile and `jmain` alias for initial configuration and basic system maintenance
- Modular build files for easy image customization

### `bootc-centos:kde`

- Customized "Workstation" installation featuring:
  - Trimmed-down KDE desktop
  - Minimal set of fonts and language packs
  - Printing support removed
  - Many packages excluded/removed (including some firmware)
- Small set of basic tools and utilities
- Basic support for document and image thumbnailing
- Some preconfigured system-wide settings
- A Justfile and `jmain` alias for initial setup and basic system maintenance
- Modular build files for easy image customization

&nbsp;<br>

### These images are intended only for my personal use
