#!/bin/bash

# Install swift
wget https://download.swift.org/swift-6.0.3-release/ubuntu2404/swift-6.0.3-RELEASE/swift-6.0.3-RELEASE-ubuntu24.04.tar.gz

tar xzf swift-6.0.3-RELEASE-ubuntu24.04.tar.gz 
sudo mv swift-6.0.3-RELEASE-ubuntu24.04 /usr/local/swift
echo "export PATH='/usr/local/swift/usr/bin:$PATH'" >> ~/.bashrc
source ~/.bashrc
rm swift-6.0.3-RELEASE-ubuntu24.04.tar.gz

# Install libc
sudo apt update
sudo apt install -y build-essential libc6-dev

# Install conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b
~/miniconda3/bin/conda init
source ~/.bashrc

# Install repos
mkdir swift_loop_linux
cd swift_loop_linux/

git clone https://github.com/tidepool-org/LoopAlgorithmToPython.git
cd LoopAlgorithmToPython
git checkout mjc/HK_update
./build.sh

cd ../

git clone https://github.com/tidepool-org/data-science-simulator.git
cd data-science-simulator
git checkout mjc/HK_update

conda env create -f conda-environment-swift.yml

# Set environment and run
conda activate tidepool-data-science-simulator-swift
export PYTHONPATH=.
python tidepool_data_science_simulator/projects/swift_api/swift_loop_example.py


