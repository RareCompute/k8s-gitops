help() {
    cat << EOF

NOTE         This machine has 65GB of persistent storage. A 2TB persistent volume is
             mounted in: /workspace. All storage is on mirrored NVMes for 2x read.


ENV          The default virtual environment is located at /config/venv and included
             in the PATH env variable by default. Use uv and condas to install/manage
             packages, e.g. uv pip install <Package>.
              
             Some python packages are installed by default: tensorflow, torch, torch-
             vision, torchaudio, transformers, numpy, pandas, matplotlib, scikit-lea-
             rn, networkx, tqdm and pydot.
             

PACKAGES     File tools are included in this Debian distribution, including: rsync,
             git, socat, aria2, wget, curl, unzip, and restic.

             Additionally: nano, vim, tree, less, man, ffmpeg, ripgrep, fzf, pciutil-
             s, tmux, htop, strace, net-tools, sudo, iftop, iotop, build-essential,
             jq, and lsb-release.

MAINTAINER   Contact Liana <liana@rarecompute.io>

EOF
}
































