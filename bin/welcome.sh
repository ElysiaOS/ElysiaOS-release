#!/bin/bash

#!/bin/bash
rm ~/bin/welcome.sh

python -m venv ~/myenv
source ~/myenv/bin/activate
pip install pypresence
pip install youtube-search-python

~/.config/hypr/welcoming/welcome
