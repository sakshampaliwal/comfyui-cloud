#!/bin/bash

# Basic setup
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install software-properties-common jq build-essential
sudo apt-get --assume-yes install linux-headers-$(uname -r)

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh -O miniconda.sh
chmod +x miniconda.sh
./miniconda.sh -b -p $HOME/miniconda3

# Initialize Conda
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda init
source ~/.bashrc

# Confirm Conda is active
conda info

# Confirm GPU hardware
lspci | grep -i nvidia
nvidia-smi || echo "NVIDIA driver not detected yet."

# Install NVIDIA drivers and CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt install ./cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit cuda

# Activate Conda base environment
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
source ~/.bashrc

# Install PyTorch with CUDA support
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

# Test CUDA availability
echo -e "import torch\nprint(torch.cuda.is_available())\nprint(torch.cuda.get_device_name(0))" > test_cuda.py
python test_cuda.py
