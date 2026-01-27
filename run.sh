#!/bin/zsh

docker run -it --rm \
    --user $(id -u):$(id -g) \
    --net=host \
    --ipc=host \
    --privileged \
    -v $(pwd)/ros2_ws:/ros2_ws \
    -v rosdep-cache:/home/ros/.ros \
    -v colcon-cache:/home/ros/.colcon \
    --name ros2-dev \
    ros2-dev \
    /bin/bash

