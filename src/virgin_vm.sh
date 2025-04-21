#!/bin/bash

sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install software-properties-common
sudo apt-get --assume-yes install jq
sudo apt-get --assume-yes install build-essential
sudo apt-get --assume-yes install linux-headers-$(uname -r)
wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh
chmod +x Miniconda3-py310_23.11.0-2-Linux-x86_64.sh
~/miniconda3/bin/conda init bash
source ~/.bashrc
export PATH="$HOME/miniconda3/bin:$PATH"

# confirm GPU is attached
lspci | grep -i nvidia

# confirm GPU not recognized
nvidia-smi

# install nvidia drivers and CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt install ./cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-toolkit
sudo apt install -y cuda

source ~/.bashrc
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

echo -e "import torch\nprint(torch.cuda.is_available())\nprint(torch.cuda.get_device_name(0))" > test_cuda.py
python test_cuda.py