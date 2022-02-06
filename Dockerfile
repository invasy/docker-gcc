ARG GCC_VERSION="11"
ARG DEBIAN_VERSION="bullseye"
FROM gcc:${GCC_VERSION}-${DEBIAN_VERSION}
LABEL maintainer="Vasiliy Polyakov <docker@invasy.dev>"

ARG CMAKE_VERSION="3.20.5"
ARG NINJA_VERSION="1.10.2"
ARG NINJA_CHECKSUM="763464859c7ef2ea3a0a10f4df40d2025d3bb9438fcb1228404640410c0ec22d"

# Update and install packages
RUN set -eu; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update -qq; apt-get upgrade -qq; \
  apt-get install -qq --no-install-recommends \
    ca-certificates \
    gdb \
    gdbserver \
    gnupg \
    make \
    openssh-server \
    rsync \
    unzip \
    wget
COPY sshd_config /etc/ssh/sshd_config
# Create user
RUN set -eu; \
  useradd --create-home --comment='C/C++ Remote Builder for CLion' --shell=/bin/bash builder; \
  yes builder | passwd --quiet builder; mkdir -p ~builder/.ssh; (\
    echo "CC=/usr/local/bin/gcc"; \
    echo "CXX=/usr/local/bin/g++"; \
  ) >~builder/.ssh/environment; \
  touch ~builder/.hushlogin; \
  chown -R builder: ~builder; chmod -R go= ~builder
# Install ninja
RUN set -eu; cd /tmp; \
  ninja_url="https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip"; \
  wget --quiet "$ninja_url"; echo "$NINJA_CHECKSUM *ninja-linux.zip" | sha256sum --quiet --check; \
  unzip -qq ninja-linux.zip -d /usr/local/bin
# Install CMake
RUN set -eu; cd /tmp; \
  cmake_url="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}" \
  cmake_pkg="cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" cmake_sum="cmake-${CMAKE_VERSION}-SHA-256.txt" \
  cmake_dir="/opt/cmake/${CMAKE_VERSION}"; \
  wget --quiet "$cmake_url/$cmake_sum" "$cmake_url/$cmake_pkg"; \
  sha256sum --quiet --check --ignore-missing "$cmake_sum"; \
  mkdir -p "/opt/cmake/${CMAKE_VERSION}" /run/sshd; \
  tar --extract --file="$cmake_pkg" --directory="$cmake_dir" \
    --strip-components=1 --wildcards '*/bin' '*/share/cmake-*/Templates' '*/share/cmake-*/Modules'; \
  for f in "$cmake_dir/bin/"*; do ln -s "$f" /usr/local/bin/; done
# Cleanup
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/* /tmp/* /root/.gnupg

ENV CC="/usr/local/bin/gcc" CXX="/usr/local/bin/g++"

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
