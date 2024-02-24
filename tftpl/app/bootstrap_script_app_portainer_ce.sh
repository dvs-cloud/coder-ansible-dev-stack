#!/bin/bash
set -e

# Installing Portainer CE if it's absent
[[ ! -e /opt/portainer/portainer ]] && {
  # Install Portainer CE
  PORTAINER_CE_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/portainer/portainer/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64' | grep '.tar.gz')
  mkdir /tmp/portainer_ce && cd /tmp/portainer_ce
  curl -fL $PORTAINER_CE_DOWNLOAD_URL -o portainer_ce.tgz
  tar -zxf portainer_ce.tgz
  mv portainer /opt/portainer
  mkdir /var/lib/portainer
  chown ${username} /var/lib/portainer

  echo '[Unit]
  Description=Portainer CE
  After=docker.service
  Wants=docker.service

  [Service]
  User=${username}
  ExecStart=/opt/portainer/portainer --bind=127.0.0.1:9000 --data=/var/lib/portainer
  Restart=always
  RestartSec=10
  TimeoutStopSec=90
  KillMode=process

  OOMScoreAdjust=-800
  SyslogIdentifier=portainer

  [Install]
  WantedBy=multi-user.target' > /etc/systemd/system/portainer.service

  systemctl enable --now portainer
}