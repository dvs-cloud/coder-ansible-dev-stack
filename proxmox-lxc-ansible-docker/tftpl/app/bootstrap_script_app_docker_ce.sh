#!/bin/bash
set -e

# Installing Docker CE and Portainer CE if it's absent
which docker > /dev/null || {
  # Install Docker CE
  curl https://get.docker.com | bash
  usermod -aG docker ${username}
}