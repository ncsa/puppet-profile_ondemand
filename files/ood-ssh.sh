#!/bin/bash

args="-o SendEnv=TERM"

TERM=xterm-256color exec /usr/bin/ssh "$args" "$@"
