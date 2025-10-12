#!/usr/bin/env bash
set -xeuo pipefail

### As some devtools pull in kernel related packages, 
### this script gets called during kernel swap to ensure the
### correct versions are installed and locked afterwards. 
### If kernel swap is excluded, this script will be called from build.sh.

# Install gcc for brew (pulls kernel-headers)
dnf -y --setopt=install_weak_deps=False install gcc

# Add other devtools as needed