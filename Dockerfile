#Adapted from https://github.com/osrf/docker_images/blob/20e3ba685bb353a3c00be9ba01c1b7a6823c9472/ros/humble/ubuntu/jammy/ros-base/Dockerfile

FROM ros:humble-ros-core-jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

#--------------------------------------------------
# System + ROS dev tools
#--------------------------------------------------
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    python3-pip \
    udev \
    sudo \
    tmux \
    wget \
    && rm -rf /var/lib/apt/lists/*

#--------------------------------------------------
# Initialize rosdep
#--------------------------------------------------
RUN rosdep init && rosdep update --rosdistro ${ROS_DISTRO}

#--------------------------------------------------
# Colcon mixins + metadata
#--------------------------------------------------
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

#--------------------------------------------------
# Robotics packages
#--------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base=0.10.0-1* \
    ros-humble-turtlebot3 \
    ros-humble-turtlebot3-msgs \
    ros-humble-dynamixel-sdk \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-rtabmap \
    ros-humble-rtabmap-ros \
    ros-humble-rviz2 \
    ros-humble-tf2-tools \
    ros-humble-cv-bridge \
    ros-humble-image-transport \
    ros-humble-vision-opencv \
    && rm -rf /var/lib/apt/lists/*

#Freeze ROS packages for stability
RUN apt-mark hold 'ros-humble-*'

#--------------------------------------------------
# Install workspace dependencies
#--------------------------------------------------
WORKDIR /tmp/ws
COPY ros2_ws/src ./src

RUN rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y

#--------------------------------------------------
# Create non-root user
#--------------------------------------------------
ARG userName=ros
ARG userId=1000
ARG groupId=1000

RUN groupadd -g ${groupId} ${userName} && \
    useradd -m -u ${userId} -g ${groupId} -s /bin/bash ${userName} && \
    echo "${userName} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${userName}
WORKDIR /ros2_ws

#--------------------------------------------------
# ROS environment setup
#--------------------------------------------------
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${userName}/.bashrc && \
    echo "source ~/ros2_ws/install/setup.bash" >> /home/${userName}/.bashrc && \
    echo "export TURTLEBOT3_MODEL=waffle_pi" >> /home/${userName}/.bashrc && \
    echo "export ROS_DOMAIN_ID=30" >> /home/${userName}/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> /home/${userName}/.bashrc

#Default environment variables (also active non-interactively)
ENV TURTLEBOT3_MODEL=waffle_pi
ENV ROS_DOMAIN_ID=30
ENV RMW_IMPLEMENTATION=rmw_f
