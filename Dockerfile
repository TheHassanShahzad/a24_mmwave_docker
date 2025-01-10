# Use the ROS 2 Humble base image
FROM ros:humble

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=humble \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Set ROS Domain ID to 12
ENV ROS_DOMAIN_ID=12
ENV TURTLEBOT3_MODEL=waffle

# Add the ROS 2 APT repository and keys
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu jammy main" > /etc/apt/sources.list.d/ros2-latest.list && \
    apt-get update

# Install necessary packages, including turtlebot3-teleop
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    git \
    ros-humble-xacro \
    ros-humble-gazebo-ros \
    ros-humble-rviz2 \
    ros-humble-control-msgs \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-topic-based-ros2-control \
    ros-humble-turtlebot3-teleop  # Added turtlebot3-teleop package

# Set up ROS 2 workspace
WORKDIR /workspace
RUN mkdir -p src

# Clone the micro-ROS-Agent repository
RUN git clone -b humble https://github.com/micro-ROS/micro-ROS-Agent.git /workspace/src/micro-ROS-Agent
RUN git clone https://github.com/TheHassanShahzad/a24_mmwave.git /workspace/src/a24_mmwave

# # Copy your additional project repository, if any
# COPY ./src /workspace/src

# Install dependencies
RUN apt-get update && rosdep install --from-paths /workspace/src --ignore-src -r -y

# Build the ROS 2 workspace
RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build

# Source the setup file by default in bash
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "source /workspace/install/setup.bash" >> ~/.bashrc

# Set default entrypoint
ENTRYPOINT ["/bin/bash"]
