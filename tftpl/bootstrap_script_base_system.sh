#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Install base packages if absent
if ! which sudo git curl wget jq htop nload vim pv > /dev/null; then
  apt update -qq && apt install -yqqq sudo git-core curl wget jq htop nload vim pv
fi

# Reconfigure locales
if grep '# en_US.UTF-8 UTF-8' /etc/locale.gen > /dev/null; then
  dpkg -l | grep 'ii\s\+locales' > /dev/null || apt update -qq && apt install -yqqq locales
  sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  dpkg-reconfigure locales  > /dev/null 2>&1
  update-locale LANG=en_US.UTF-8 > /dev/null 2>&1
fi

# Create new user if absent
getent passwd '${username}' > /dev/null || {
  adduser \
    --shell /bin/bash \
    --gecos 'User for workspace owner' \
    --disabled-password \
    --home '/home/${username}' \
    '${username}'
}

# Re-configure sudo for user
usermod -aG sudo ${username}
echo '${username} ALL=(ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/${username}

# Create home folder if absent
[[ ! -d '/home/${username}' ]] && {
  mkdir -p '/home/${username}'
  chown $(id -u ${username}):$(id -g ${username}) '/home/${username}'
}

# Move templates linuxbrew folder if needed
[[ ! -d '/home/linuxbrew' ]] && [[ -d /opt/linuxbrew ]] && {
  mv /opt/linuxbrew /home/linuxbrew
  chown $(id -u ${username}):$(id -g ${username}) '/home/linuxbrew'
}

# Run ansible playbook
set -x
if [[ -f '/opt/ansibleplaybook.tgz' ]]; then
  rm -rf /opt/playbook && mkdir -p /opt/playbook
  tar -zxf /opt/ansibleplaybook.tgz --strip-components=1 -C /opt/playbook/
  if [[ -f /opt/playbook/run.sh ]]; then
    bash /opt/playbook/run.sh --tags=base-system,zsh,${ansible_paybook_tags}
  else
    >&2 echo "run.sh does not exists in the playbook archive"
    exit 1
  fi
fi
set +x