# tinet-rb

Ruby implement of [slankdev/tinet](https://github.com/slankdev/tinet).

:warning: **This is now prototype version. And also it is incompatible with YAML config format in [slankdev/tinet](https://github.com/slankdev/tinet).**

## Requirements

- Docker
- Open vSwitch

## Install

```
$ gem install tinet
```

## Usage

```
$ tinet [OPTIONS] COMMAND

Options:
  -f, [--specfile=SPECFILE]  # Specify specification YAML file (Default: ./spec.yml)
  -d, [--dry-run]            # Print the recipes that are needed to execute
  -v, [--version]            # Show the TINET version information

Commands:
  tinet build [OPTIONS]              # Build Docker images from the spec file
  tinet conf [OPTIONS]               # Execute commands in a running container
  tinet down [OPTIONS]               # Stop and remove containers
  tinet exec [OPTIONS] NODE COMMAND  # Execute a command in a running container
  tinet help [COMMAND]               # Describe available commands or one specific command
  tinet init                         # Generate template spec file
  tinet ps [OPTIONS]                 # List services
  tinet pull [OPTIONS]               # Pull service images
  tinet restart [OPTIONS]            # Down and Up running containers
  tinet up [OPTIONS]                 # Create and start containers
  tinet version                      # Show the TINET version information
```
