FROM osrf/ros:jazzy-desktop-full

ENV QT_X11_NO_MITSHM=1
ENV EDITOR=nano
ENV ROS_DISTRO=jazzy

RUN echo "[INFO] Update Ubuntu" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -o Dpkg::Options::="--force-confnew" -fuy \
    nano sudo wslu keychain rsync software-properties-common && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -o Dpkg::Options::="--force-confnew" -fuy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "[INFO] Set locale" && \
    apt-get update && \
    apt-get install locales && \
    locale-gen en_GB en_GB.UTF-8 && \
    update-locale LC_ALL=en_GB.UTF-8 LANG=en_GB.UTF-8

RUN echo "[INFO] Update Git" && \
    apt-add-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "[INFO] Install Various System Tools" && \
    apt-get update && \
    apt-get install -y \
    curl \
    cmake \
    less \
    eog \
    dos2unix \
    vim \
    tmux \
    tree \
    wget \
    ffmpeg \
    xorg-dev \
    libglu1-mesa-dev \
    python3-pip \
    python3-venv \
    python3-scipy \
    python3-pandas \
    python3-pydantic \
    python3-venv \
    python3-pydantic && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "[INFO] Install Additional ROS tools" && \
    apt-get update && \
    apt-get install -y \
    ros-dev-tools \
    python3-rosdep \
    python3-colcon-common-extensions \
    ros-${ROS_DISTRO}-gazebo-* \
    ros-${ROS_DISTRO}-cartographer \
    ros-${ROS_DISTRO}-cartographer-ros \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-rmw-zenoh-cpp

RUN echo "[INFO] Install TB3 related stuff" && \
    apt-get update && \
    apt-get install -y \
    ros-${ROS_DISTRO}-turtlebot3 \
    ros-${ROS_DISTRO}-turtlebot3-msgs \
    ros-${ROS_DISTRO}-turtlebot3-simulations \
    ros-${ROS_DISTRO}-turtlebot3-gazebo \
    ros-${ROS_DISTRO}-librealsense2* \
    ros-${ROS_DISTRO}-realsense2-* \
    ros-${ROS_DISTRO}-dynamixel-sdk

RUN useradd -ms /bin/bash student \
    && echo "student:password" | chpasswd

RUN apt-get update && apt-get install -y sudo && \
    usermod -aG sudo student && \
    echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Try to install starship, but don't fail if it doesn't work
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes || true

USER student
# Disable sudo warning
RUN touch ~/.hushlogin
RUN mkdir ~/.diamond
RUN mkdir -p ~/ros2_ws/src/
RUN mkdir ~/.ssh

# Only add starship init if starship was successfully installed
RUN if [ -f "/usr/local/bin/starship" ]; then \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc; \
    fi

COPY source/bash_aliases ~/.bash_aliases
COPY source/laptop_config.sh ~/.diamond/laptop_config.sh
RUN echo "source ~/.diamond/laptop_config.sh" >> ~/.bashrc



