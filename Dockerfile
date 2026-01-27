#Adapted from https://github.com/osrf/docker_images/blob/20e3ba685bb353a3c00be9ba01c1b7a6823c9472/ros/humble/ubuntu/jammy/ros-base/Dockerfile

FROM ros:humble-ros-core-jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# install bootstrap tools
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
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && rosdep update --rosdistro $ROS_DISTRO

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

# install ros2 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-base=0.10.0-1* \
    && rm -rf /var/lib/apt/lists/*

#Create non-root user
ARG userName=ros
ARG userId=1000
ARG groupId=1000

RUN groupadd -g ${groupId} ${userName} && \
    useradd -m -u ${userId} -g ${groupId} -s /bin/bash ${userName} && \
    echo "${userName} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${userName}
WORKDIR /ros2_ws

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${userName}/.bashrc
RUN echo "source /ros2_ws/install/setup.bash" >> /home/${userName}/.bashrc || true

ENTRYPOINT ["/ros2_ws/docker/entrypoint.sh"]

