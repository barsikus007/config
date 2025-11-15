#!/bin/sh
if [ -x /usr/bin/fish ] && [ "$0" != "/usr/bin/fish" ]; then
    SHELL=/usr/bin/fish
    exec /usr/bin/fish
fi
