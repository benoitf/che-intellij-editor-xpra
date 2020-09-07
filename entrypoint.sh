#!/bin/sh
#
# Copyright (c) 2019-2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Ensure $HOME exists when starting
if [ ! -d "${HOME}" ]; then
  mkdir -p "${HOME}"
fi

# Setup $PS1 for a consistent and reasonable prompt
if [ -w "${HOME}" ] && [ ! -f "${HOME}"/.bashrc ]; then
  echo "PS1='\s-\v \w \$ '" > "${HOME}"/.bashrc
fi

# Add current (arbitrary) user to /etc/passwd and /etc/group
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "update passwd file"
    echo "${USER_NAME:-user}:x:$(id -u):0:${USER_NAME:-user} user:${HOME}:/bin/bash" >> /etc/passwd
    echo "${USER_NAME:-user}:x:$(id -u):" >> /etc/group
  fi
fi

mkdir -p /run/user/$(id -u)/xpra
XPRA_NET_WM_NAME=Sawfish xpra start :100 --resize-display=yes --html=on --notifications=no --pulseaudio=no --mdns=no --start-child="/ideaIC-2020.2.1/bin/idea.sh" --bind-tcp=0.0.0.0:8080 --no-daemon --exit-with-children
