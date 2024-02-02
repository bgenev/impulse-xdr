#!/bin/sh

cd /opt/impulse/managerd

flask db migrate 
flask db upgrade

pip3 install --no-cache-dir wheel --default-timeout=100
pip3 install --no-cache-dir -r requirements.txt --default-timeout=100

## Dev
python3 /usr/local/bin/gunicorn -b 127.0.0.1:5020 --reload wsgi:app --timeout 900




