# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/datascience-notebook:stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN apt update && apt upgrade -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:graphics-drivers/ppa && apt-get update

# Install os-level packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    htop \
    libegl1 \
    libxext6 \
    libjpeg-dev \
    libpng-dev  \
    libvulkan1 \
    rsync \
    tmux \
    unzip \
    vim \
    vulkan-tools \
    wget \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 3) install packages using notebook user
USER jovyan

# https://github.com/haosulab/ManiSkill/issues/9
COPY nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY nvidia_layers.json /etc/vulkan/implicit_layer.d/nvidia_layers.json
COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# install dependencies
RUN pip install --upgrade mani-skill==3.0.0b20
# download physx GPU binary via sapien
RUN python -c "exec('import sapien.physx as physx;\ntry:\n  physx.enable_gpu()\nexcept:\n  pass;')"