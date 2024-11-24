ARG UNAME=px4dev
ARG UID=1000
ARG GID=1000
ARG USE_NVIDIA
ARG PX4_TAG="v1.15.2"
ARG ARDUPILOT_TAG="Copter-4.5.7"

FROM px4io/px4-dev-ros-noetic as base
ENV DEBIAN_FRONTEND noninteractive
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

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
    libgz-sim7-dev \
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

# User vars
RUN export uid=${UID} gid=${GID} && \
    mkdir -p /home/${UNAME} && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME}
ENV HOME /home/$UNAME
USER $UNAME

# ROS vars
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Nvidia GPU vars
# Please, refer to https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# And use nvidia-contairnerd-toolkit for better performance
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
RUN if [[ -z "${USE_NVIDIA}" ]] ;\
    then printf "export QT_GRAPHICSSYSTEM=native" >> /home/${UNAME}/.bashrc ;\
    else echo "Native rendering support disabled" ;\
    fi

FROM base AS sources
WORKDIR $HOME
RUN git clone --depth 1 --branch $PX4_TAG --recurse-submodules https://github.com/PX4/PX4-Autopilot.git
RUN git clone --depth 1 --branch $ARDUPILOT_TAG --recurse-submodules https://github.com/ArduPilot/ardupilot.git
RUN git clone --depth 1 --recurse-submodules https://github.com/PX4/Firmware.git

ENV GZ_VERSION garden
RUN sudo bash -c 'wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list'
RUN rosdep update
RUN rosdep resolve gz-garden
RUN git clone --depth 1 --recurse-submodules https://github.com/ArduPilot/ardupilot_gazebo

WORKDIR $HOME/catkin_ws/src
RUN git clone --depth 1 --recurse-submodules https://github.com/RuslanAgishev/px4_control/

FROM sources AS build_deps
# TODO: build

FROM build_deps AS build_ros
# TODO: build
RUN echo "source ${HOME}/catkin_ws/devel/setup.bash --extend" >> ~/.bashrc
