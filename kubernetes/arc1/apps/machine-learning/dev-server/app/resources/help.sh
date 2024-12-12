help() {
    cat << EOF

NOTE         This machine has 100GB of persistent storage. A 2TB persistent volume is
             mounted in: /workspace. All storage is on mirrored NVMes for 2x read


ENV          The default virtual environment is located at /opt/venv and this machine
             has been configured with uv (e.g. uv pip install <Package>) and conda s-
             upport

PACKAGES     File tools are included in this Debian distribution, including: rsync,
             git, socat, aria2, wget, curl, unzip, and restic.

             Additionally: nano, vim, tree, less, man, ffmpeg, ripgrep, fzf, pciutil-
             s, tmux, htop, strace, net-tools, sudo, iftop, iotop, build-essential,
             jq, and lsb-release.

MAINTAINER   Contact Liana <liana@rarecompute.io>

EOF
}
































