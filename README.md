## Bootc CentOS Workstation

An atomic workstation built on the CentOS Stream 10 `bootc` image.

### Currently Building Image: `bootc-centos:latest`

- Backported GNOME 48 from the CentOS Hyperscale SIG  
- Customized "Workstation" installation:
    - Minimal set of fonts and language packs
    - Printing support removed
    - Some packages excluded in favor of Flatpak versions
- Small set of basic tools and utilities, including GCC for Homebrew
- Basic support for image thumbnailing and previews
- Some pre-configured system-wide settings   
- Justfile and `jmain` alias for initial configuration and basic system maintenance
- Modular build files for easy image customization

&nbsp;<br>

### This image is intended only for my personal use ⚠️

While functional, it should be considered experimental. Use at your own risk.

&nbsp;<br>

---


<p align="center">
<strong><font size="+1">Inspired by:</font></strong><br>
<a href="https://github.com/ublue-os/bluefin-lts">Bluefin LTS</a>, 
<a href="https://github.com/HeliumOS-org/HeliumOS">HeliumOS</a> and 
<a href="https://github.com/AlmaLinux/atomic-desktop">AlmaLinux Atomic Desktop</a>
</p>