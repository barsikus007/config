Test-Path Alias:\nv && Remove-Item Alias:\nv -Force
Function nv { editor $(fzf) }

Function cu { cd ~/config/ && git pull && ./configs/install.ps1 && ./windows/pwsh.ps1 && cd - }

Function pipi { uv pip install -r requirements.txt || uv pip install -r pyproject.toml }
Function pyvcr { uv venv --allow-existing && .venv\Scripts\activate && (pipi) }
Function pyv { .venv/Scripts/activate || (pyvcr) }
