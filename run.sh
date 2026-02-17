#!/bin/zsh

docker run -it --rm \
    --user $(id -u):$(id -g) \
    --net=host \
    --ipc=host \
    --privileged \
    -v $(pwd)/ros2_ws:/ros2_ws \
    -v rosdep-cache:/home/ros/.ros \
    -v colcon-cache:/home/ros/.colcon \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --name ros2-dev \
    ros2-dev \
    /bin/bash

