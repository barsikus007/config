#!/bin/sh
if [ -x /bin/bash ] && [ "$0" != "/bin/bash" ]; then
    echo "Switching to bash shell..."
    SHELL=/bin/bash
    exec /bin/bash
fi
