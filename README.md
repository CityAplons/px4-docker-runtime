# Sample ROS1 workspace for running various SITL for PX4 and Ardupilot projects

> This code is experimental. The Docker container runs in privileged mode, so it is not suited for production or public access!

## Description

You may use root of this project as a workspace for ROS1. Just create src/ directory and move your packages.

The script "docker_run" will prepare and run docker container, where:

- your display is forwarded to a container to run Gazebo or any other GL app;
- supported hardware acceleration for rendering.
  !!! However, drivers for nvidia/amd cards are not installed.
  !!! After the container is created, please install them manually using the same version as the host;
- additional fonts and icons are borrowed from your host system;
- root of this project is mounted as volume to a ~/volumed_ws;
- other ros1 dependencies, described in [ws_deps.sh](./scripts/ws_deps.sh) install in ~/thirdparty_ws;
- PX4, Ardupilot projects are located in ~/;
- QGroundControl app is located in ~/ also;
- all workspaces already written to a ~/.bashrc.

The default container user name is "sim". In order to change it, re-write UNAME env in [docker_run](./docker_run) and [Dockerfile](./Dockerfile).
The default container name is "sim-runtime-container", you may override them by environment variables "NAME": `NAME='my_container' ./docker_run`.

## Installation

1. Prerequisites:
   - docker engine
   - bash
2. Build, Create & Run the container:

   The first exection will take around 15 minutes, keep patient.

   ```shell
   ./docker_run 
   ```

3. Connecting to an already running container

   ```shell
   docker exec -it sim-runtime-container bash
   ```

4. Remove container and image

   ```shell
   docker rm sim-runtime-container
   docker rmi sim-runtime
   ```

## Sample commands to run simulation

### PX4

```shell
cd ~/PX4-Autopilot
make px4_sitl gz_x500
```


### Ardupilot with Gazebo

#### 1-st session

```shell
gz sim -v4 -r iris_runway.sdf
```

#### 2-nd session

```shell
cd ~/ardupilot/ArduCopter
../Tools/autotest/sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --map --console
```

## byobu

There is a pre-installed shell multiplexer which you can use.
Cheatsheet:

```md
byobu keybindings can be user defined in /usr/share/byobu/keybindings/ (or within .screenrc if byobu-export was used). 
The  common  key  bindings are:
    F2 - Create a new window
    F3 - Move to previous window
    F4 - Move to next window
    
    F5 - Reload profile
    F6 - Detach from this session
    F7 - Enter copy/scrollback mode

    F8 - Re-title a window
    F9 - Configuration Menu
    F12 -  Lock this terminal

    shift-F2 - Split the screen horizontally
    ctrl-F2 - Split the screen vertically

    shift-F3 - Shift the focus to the previous split region
    shift-F4 - Shift the focus to the next split region
    shift-F5 - Join all splits
    ctrl-F6 - Remove this split
    
    ctrl-F5 - Reconnect GPG and SSH sockets
    shift-F6 - Detach, but do not logout
    alt-pgup - Enter scrollback mode
    alt-pgdn - Enter scrollback mode

    Ctrl-a $ - show detailed status
    Ctrl-a R - Reload profile
    Ctrl-a ! - Toggle key bindings on and off
    Ctrl-a k - Kill the current window
    Ctrl-a ~ - Save the current window's scrollback buffer
    Ctrl+shift + f3 - Move to left tab
    Ctrl+shift + f4 - Move to right tab
```
