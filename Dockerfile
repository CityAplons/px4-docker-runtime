FROM px4io/px4-dev-ros-noetic AS base
ENV DEBIAN_FRONTEND=noninteractive
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

ARG UNAME=sim
ARG USE_NVIDIA=1

# System Dependencies
RUN apt-get update \
    && apt-get install -y -qq --no-install-recommends \
    python-is-python3 \
    apt-utils \
    byobu \
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
    gz-garden \
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
RUN echo "export GZ_VERSION='garden'" >> ~/.bashrc
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

FROM base AS sys_deps
WORKDIR $HOME
COPY --chown=$UNAME:$UNAME scripts/sys_deps.sh ./
RUN ./sys_deps.sh

FROM sys_deps AS build_sys_deps
WORKDIR $HOME
COPY --chown=$UNAME:$UNAME scripts/build_ardupilot_gazebo.sh ./
RUN ./build_ardupilot_gazebo.sh

FROM build_sys_deps AS build_ros
WORKDIR $HOME/thirdparty_ws/src
COPY --chown=$UNAME:$UNAME scripts/ws_deps.sh ./
RUN ./ws_deps.sh
WORKDIR $HOME/thirdparty_ws
RUN source /opt/ros/noetic/setup.bash && catkin_make
RUN echo "source ${HOME}/thirdparty_ws/devel/setup.bash --extend" >> ~/.bashrc

FROM build_ros AS final
WORKDIR $HOME/volumed_ws
RUN echo "source ${HOME}/volumed_ws/devel/setup.bash --extend 2> /dev/null" >> ~/.bashrc
