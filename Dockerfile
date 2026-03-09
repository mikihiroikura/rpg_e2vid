FROM nvidia/cuda:11.1.1-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

ARG CODE_DIR=/usr/local/src

RUN apt update

# Add User ID and Group ID
ARG UNAME=e2vid
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# Add User into sudoers, can run sudo command without password
RUN apt update && apt install -y sudo
RUN usermod -aG sudo ${UNAME}
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/${UNAME}

#basic environment
RUN apt install -y \
    ca-certificates \
    build-essential \
    git \
    cmake \
    cmake-curses-gui \
    libace-dev \
    libassimp-dev \
    libglew-dev \
    libglfw3-dev \
    libglm-dev \
    libeigen3-dev \
    clang-format

#my favourites
RUN apt install -y \
    vim \
    gdb \
    libpython3-dev \
    python3-dev

# Copy codes
COPY ./ /app/rpg_e2vid

# Change owner of some folders for the development
RUN chown -R $UNAME:$UNAME $CODE_DIR
RUN chown -R $UNAME:$UNAME /app

USER $UNAME
WORKDIR /home/${UNAME}

# Install uv
RUN sudo apt-get install curl -y
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create python virtual environment via uv
ENV PATH="/home/e2vid/.local/bin:$PATH"
RUN cd /app/rpg_e2vid && \
    uv pip install torch --torch-backend=auto && \
    uv sync