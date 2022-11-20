# Remote Development Environment for CLion with GCC and CMake

> ***Warning***: Development continues in [`invasy/dev-env`](https://github.com/invasy/dev-env "invasy/dev-env") repository.

## Toolchain
- [GCC][] 11
- [CMake][] 3.20.5
- [ninja][] 1.10.2
- [GNU Make][make] 4.2.1
- [GNU Debugger][gdb] (gdb) with gdbserver 9.2
- [rsync][] 3.1.3
- [OpenSSH][] server 8.2p1
- [Debian 11 "bullseye"][Debian]

_Note_: CMake versions 3.21.* are not supported by CLion versions up to 2021.2.*.

## Usage
1. Run service (container).
2. Set up CLion toolchain.
3. Build, run, debug your project in the container.

### Run container
```bash
docker run -d --cap-add=sys_admin --name=gcc_remote -p 127.0.0.1:22002:22 invasy/gcc-remote:latest
```
or from git repository:
```bash
docker-compose up -d
```

### CLion Configuration
#### Toolchains
- **Name**: `gcc-remote`
- **Credentials**: _see **SSH Configurations** below_
- **CMake**: `/usr/local/bin/cmake`
- **Make**: `/usr/local/bin/ninja` (_see also **CMake** below_)
- **C Compiler**: `/usr/local/bin/gcc` (_should be detected_)
- **C++ Compiler**: `/usr/local/bin/g++` (_should be detected_)
- **Debugger**: `/usr/bin/gdb` (_should be detected_)

#### SSH Configurations
- **Host**: `127.0.0.1`
- **Port**: `22002`
- **Authentication type**: `Password`
- **User name**: `builder`
- **Password**: `builder`

#### CMake
- **Profiles**:
  - **Debug** (_or any other profile_):
    - **CMake options**: `-G Ninja`

## SSH
### Configuration
```
# ~/.ssh/config
Host gcc-remote
User builder
HostName 127.0.0.1
Port 22002
HostKeyAlias gcc-remote
StrictHostKeyChecking no
NoHostAuthenticationForLocalhost yes
PreferredAuthentications password
PasswordAuthentication yes
PubkeyAuthentication no
```

Remove old host key from `~/.ssh/known_hosts` after image rebuilding (_note `HostKeyAlias` in config above_):
```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "gcc-remote"
```

### Connection
```bash
ssh gcc-remote
```
Password: `builder`

## See Also
- [Remote development | CLion](https://www.jetbrains.com/help/clion/remote-development.html "Remote development | CLion")
- [Using Docker with CLion — The CLion Blog](https://blog.jetbrains.com/clion/2020/01/using-docker-with-clion/ "Using Docker with CLion — The CLion Blog")

[github]: https://github.com/invasy/gcc-remote "invasy/gcc-remote @ GitHub"
[gitlab]: https://gitlab.com/invasy/gcc-remote "invasy/gcc-remote @ GitLab"
[bitbucket]: https://bitbucket.org/invasy/gcc-remote "invasy/gcc-remote @ Bitbucket"
[travis]: https://app.travis-ci.com/invasy/gcc-remote "invasy/gcc-remote @ Travis CI"
[dockerhub]: https://hub.docker.com/r/invasy/gcc-remote "invasy/gcc-remote @ DockerHub"
[badge-github]: https://img.shields.io/badge/GitHub-invasy%2Fgcc--remote-informational?logo=github "invasy/gcc-remote @ GitHub"
[badge-gitlab]: https://img.shields.io/badge/GitLab-invasy%2Fgcc--remote-informational?logo=gitlab "invasy/gcc-remote @ GitLab"
[badge-bitbucket]: https://img.shields.io/badge/Bitbucket-invasy%2Fgcc--remote-informational?logo=bitbucket "invasy/gcc-remote @ Bitbucket"
[badge-travis]: https://app.travis-ci.com/invasy/gcc-remote.svg?branch=master "invasy/clang-remote @ Travis CI"
[badge-build]: https://img.shields.io/docker/cloud/build/invasy/gcc-remote "Docker Automated Build Status"
[badge-size]: https://img.shields.io/docker/image-size/invasy/gcc-remote?sort=date "Docker Image Size (latest by date)"
[badge-pulls]: https://img.shields.io/docker/pulls/invasy/gcc-remote "Docker Pulls"
[gcc]: https://gcc.gnu.org/ "GCC, the GNU Compiler Collection"
[CMake]: https://cmake.org/ "CMake"
[ninja]: https://ninja-build.org/ "Ninja, a small build system with a focus on speed"
[make]: https://www.gnu.org/software/make/ "GNU Make"
[gdb]: https://www.gnu.org/software/gdb/ "GNU Debugger"
[rsync]: https://rsync.samba.org/ "rsync"
[OpenSSH]: https://www.openssh.com/ "OpenSSH"
[Debian]: https://www.debian.org/releases/bullseye/ "Debian 11 “bullseye”"
