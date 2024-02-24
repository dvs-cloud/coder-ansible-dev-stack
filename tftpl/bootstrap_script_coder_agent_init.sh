#!/bin/bash
set -e

mkdir -p /opt/coder
echo '${coder_agent_init_script}' | tee /opt/coder/init
chmod 0755 /opt/coder/init

echo '[Unit]
Description=Coder Agent
After=network-online.target
Wants=network-online.target

[Service]
User=${username}
ExecStart=/opt/coder/init
Environment=CODER_AGENT_TOKEN=${coder_agent_token}
Restart=always
RestartSec=10
TimeoutStopSec=90
KillMode=process

OOMScoreAdjust=-900
SyslogIdentifier=coder-agent

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/coder-agent.service

systemctl daemon-reload
systemctl enable coder-agent
systemctl stop coder-agent
systemctl start coder-agent