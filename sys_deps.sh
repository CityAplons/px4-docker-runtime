#!/bin/bash

PX4_TAG="v1.15.2"
ARDUPILOT_TAG="Copter-4.5.7"
GZ_VERSION="garden"

wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage
chmod +x QGroundControl.AppImage

curl -sSL http://get.gazebosim.org | sh
sudo wget https://raw.githubusercontent.com/osrf/osrf-rosdep/master/gz/00-gazebo.list -O /etc/ros/rosdep/sources.list.d/00-gazebo.list
rosdep update
rosdep resolve gz-garden

git clone --depth 1 --recurse-submodules https://github.com/ArduPilot/ardupilot_gazebo
git clone --depth 1 --branch $PX4_TAG --recurse-submodules https://github.com/PX4/PX4-Autopilot.git
git clone --depth 1 --branch $ARDUPILOT_TAG --recurse-submodules https://github.com/ArduPilot/ardupilot.git
