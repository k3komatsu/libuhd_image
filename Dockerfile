FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
    apt update
    apt install -y curl file gcc wget python3 python3-pip \
        autoconf automake build-essential ccache cmake cpufrequtils doxygen ethtool pkg-config \
        g++ git inetutils-tools libboost-all-dev libncurses-dev libusb-1.0-0 libusb-1.0-0-dev \
        libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools \
        python3-ruamel.yaml libboost-all-dev nlohmann-json3-dev clang gdb libfftw3-dev
EOF

SHELL ["/bin/bash", "-c"]

# install UHD
RUN <<EOF
    cd ~
    mkdir -p tmp
    cd tmp
    wget https://github.com/EttusResearch/uhd/archive/refs/tags/v4.9.0.1.tar.gz
    tar -xf v4.9.0.1.tar.gz
    cd uhd-4.9.0.1/host
    mkdir build
    cd build
    cmake -DCMAKE_FIND_ROOT_PATH=/usr ../
    JOBS=$(($(grep cpu.cores /proc/cpuinfo | sort -u | sed 's/[^0-9]//g') + 1))
    make -j${JOBS}
    make test
    make install
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib' >> /root/.bashrc
    uhd_images_downloader
EOF
