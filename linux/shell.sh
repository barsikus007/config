#!/bin/sh

{
  register-python-argcomplete pipx;
  pdm completion bash;
  _HATCH_COMPLETE=bash_source hatch;
  starship completions bash;
} >> ~/.bash_completion
# pdm completion bash > /etc/bash_completion.d/pdm.bash-completion
