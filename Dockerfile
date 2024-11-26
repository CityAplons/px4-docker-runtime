FROM px4io/px4-dev-ros-noetic AS base
ENV DEBIAN_FRONTEND=noninteractive
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

ARG UNAME=px4dev
ARG USE_NVIDIA=1

# System Dependencies
RUN apt-get update \
    && apt-get install -y -qq --no-install-recommends \
    apt-utils \
    fuse \
    git \
    libxext6 \
    libx11-6 \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libfuse-dev \
    libpulse-mainloop-glib0 \
    rapidjson-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \ 
    gstreamer1.0-gl \
    iputils-ping \
    nano \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Python deps
RUN sudo pip install PyYAML MAVProxy

# User
RUN adduser --disabled-password --gecos '' $UNAME
RUN adduser $UNAME sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV HOME=/home/$UNAME
USER $UNAME

# ROS vars
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Nvidia GPU vars
# Please, refer to https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# And use nvidia-contairnerd-toolkit for better performance
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
RUN if [[ -z "${USE_NVIDIA}" ]] ;\
    then printf "export QT_GRAPHICSSYSTEM=native" >> /home/${UNAME}/.bashrc ;\
    else echo "Native rendering support disabled" ;\
    fi

FROM base AS sources
WORKDIR $HOME
COPY --chown=$UNAME:$UNAME sys_deps.sh ./
RUN ./sys_deps.sh
WORKDIR $HOME/catkin_ws/src
COPY --chown=$UNAME:$UNAME ws_deps.sh ./
RUN ./ws_deps.sh

FROM sources AS build_deps
# TODO: build

FROM build_deps AS build_ros
# TODO: build
RUN echo "source ${HOME}/catkin_ws/devel/setup.bash --extend" >> ~/.bashrc
