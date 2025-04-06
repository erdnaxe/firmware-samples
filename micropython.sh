#!/bin/sh
# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT
# Hacky script to quickly collect firmware download URLs for a specific MicroPython release.
set -e

MICROPYTHON_VERSION=1.24.1

mkdir -p result/micropython

boards=$(curl -s https://micropython.org/download/ | grep -Po '(?<=<a class="board-card" href=")[^"]+')
for board in $boards; do
    paths=$(curl -s "https://micropython.org/download/$board/" | grep -Po "(?<=<a href=\")/resources/firmware/[^\"]+-v$MICROPYTHON_VERSION.[^\"]+")
    for path in $paths; do
        echo "Fetching https://micropython.org$path"
        (cd result/micropython && curl -C - "https://micropython.org$path" -O)
    done
done
