#!/usr/bin/env bash

if ! grep -q wspace /etc/passwd;then
    useradd -m wspace
    [ $? -ne 0 ] && echo "Error: some error happened while creating user wspace" \
        exit 1
fi
