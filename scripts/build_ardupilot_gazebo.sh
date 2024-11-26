#!/bin/bash

WORKDIR="ardupilot_gazebo/"
BUILDDIR="$WORKDIR/build"

cmake -S "$WORKDIR" -B "$BUILDDIR"
make -sj -C "$BUILDDIR"
sudo make install -C "$BUILDDIR"

echo 'export NO_AT_BRIDGE=1' >> $HOME/.bashrc
echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> $HOME/.bashrc
echo 'export GZ_SIM_RESOURCE_PATH=$HOME/ardupilot_gazebo/models:$HOME/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> $HOME/.bashrc
