#!/bin/bash

echo "Installing/Upgrading btop++"
mkdir btopinst && cd btopinst
wget -q https://github.com/aristocratos/btop/releases/latest/download/btop-"$(uname -m)"-linux-musl.tbz -O btop.tbz && \
tar -xjvf btop.tbz &> /dev/null && \
cd btop && \
sudo make -s install &> /dev/null && \
cd ..
cd .. && rm -rf ./btopinst
