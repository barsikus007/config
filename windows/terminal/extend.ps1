Test-Path Alias:\nv && Remove-Item Alias:\nv -Force
Function nv { editor $(fzf) }

Function cu { cd ~/config/ && git pull && ./configs/install.ps1 && ./windows/pwsh.ps1 && cd - }

Function pyvcr { python3 -m venv .venv --upgrade-deps && .venv/Scripts/python -c "import sys,pathlib;v=sys.version_info;pyv=f'{v.major}.{v.minor}';path=pathlib.Path('.venv/pyvenv.cfg');path.write_text(path.read_text(encoding='utf-8').replace(f'{v.major}.{v.minor}.{v.micro}',pyv).replace(f'{pyv}\\','current\\'),encoding='utf-8')" && .venv/Scripts/Activate.ps1 && .venv/Scripts/pip install -r requirements.txt }
Function pyv { .venv/Scripts/Activate.ps1 || (pyvcr) }
Function pipi { python -c "import os;os.environ['VIRTUAL_ENV']" && pip install -r requirements.txt || echo "activate venv to install requirements" }
