
FROM ros:humble

ENV HOME=/home/blah
ENV ROS2_WORKSPACE=workspace
ARG ROS_DISTRO=humble

## Basic Packages install
## For any other packages needed- please add to this apt-get installation!
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    gnupg \
    lsb-release \
    git \
    apt-utils \
    python3-dev \
    python3-distutils \
    python3-pip \
    unzip \
    sudo \
    wget \
    software-properties-common \
    iputils-ping \
    vim \
    figlet \
    toilet

RUN apt-get update  && \
    apt-get upgrade -y && \
    apt-get install -y \
    vim \
    iputils-ping \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-xacro \
    python3-rosdep \
    python3-colcon-core \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-vcstool

#Update ROS2
RUN rosdep update --rosdistro=$ROS_DISTRO && \
    apt dist-upgrade

RUN apt install -y ros-${ROS_DISTRO}-ur

RUN mkdir -p $HOME/$ROS2_WORKSPACE

# Copy source code
COPY src $HOME/$ROS2_WORKSPACE/src/

# Initialize and install dependencies
RUN cd $HOME/$ROS2_WORKSPACE && \
    . /opt/ros/$ROS_DISTRO/setup.sh && \
    rosdep init || echo "rosdep init already completed" && \
    rosdep update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro humble && \
    colcon build --executor sequential

RUN apt install -y python3-pip && \
    pip install paho-mqtt \
    pyquaternion

RUN echo "source /opt/ros/$ROS_DISTRO/setup.sh" >> $HOME/$ROS2_WORKSPACE/.bash_sources    
RUN echo "source $HOME/$ROS2_WORKSPACE/install/setup.bash" >> $HOME/$ROS2_WORKSPACE/.bash_sources
CMD ["bash", "-c", "source $HOME/$ROS2_WORKSPACE/.bash_sources && ros2 launch qb_integration_control UR5e.launch.py generate_collision_object:=true"]
