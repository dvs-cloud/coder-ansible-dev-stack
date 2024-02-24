#!/bin/bash
set -e

# Installing Code-Server if it's absent
which code-server > /dev/null || {
  CODE_SERVER_DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | jq -r '.assets[].browser_download_url' | grep 'amd64.deb')
  curl -fL $CODE_SERVER_DOWNLOAD_URL -o /tmp/code_server.deb
  dpkg -i /tmp/code_server.deb
  rm /tmp/code_server.deb

  systemctl enable --now code-server@${username}
}