## Bootc CentOS Workstation

An opinionated atomic workstation based on the CentOS Stream 10 `bootc` image.

### Currently building image: `bootc-centos:latest`

- Backported GNOME 48 from the CentOS Hyperscale SIG  
- Trimmed "Workstation" install  
- Small set of opinionated tools and utilities  
- Basic support for image thumbnailing, previews, etc.  
- Some pre-configured system-wide settings  
- Flathub enabled by default:  
    - Firefox ESR not installed in favor of the Flatpak version  
    - Alias `defpaks` to install default flatpaks  

### `build_files`:

- Modular design; specific build scripts can be excluded in `build.sh`  
- All build scripts are tracked with `time`  
- Global package exclusion and DNF settings can be configured in `00-base.sh`  

- Optional build scripts for:  
    - Kernel swap (latest Hyperscale kernel, pinned kmods mainline kernel, or kmods LTS kernel — 6.18 not available yet)  
    - Non-free media codecs (from Negativo17)  
    - Virtualization support  
    - VSCode and/or Docker installation  

- "Workstation" install with opinionated trimmings:  
    - Fully functional GNOME desktop with required packages for general desktop use  
    - Minimal set of fonts  
    - Minimal set of language packs  
    - No printing support  
    - Some unnecessary packages excluded or removed  


These trimmings reduce a fair amount of build time and bandwidth, and make the final image a few hundred MBs smaller (which speeds up rechunker and pushing to GHCR in CI). As this image is built solely for personal use, there is no need to include comprehensive language or localisation support. Fonts can be installed and updated locally, so there is no reason to include them in every image.

&nbsp;<br>

### ⚠️ This image is intended only for my personal use ⚠️

While functional, it should be considered experimental.

I may change installed packages, kernel, or preferences at any time. Use at your own risk.

I strongly recommend forking the repo and building your own image, or using a larger community project instead.

&nbsp;<br>

---
&nbsp;<br>

<p align="center">
<strong><font size="+1">Inspired by:</font></strong><br>
<a href="https://github.com/ublue-os/bluefin-lts">Bluefin LTS</a>, 
<a href="https://github.com/HeliumOS-org/HeliumOS">HeliumOS</a> and 
<a href="https://github.com/AlmaLinux/atomic-desktop">AlmaLinux Atomic Desktop</a>
</p>