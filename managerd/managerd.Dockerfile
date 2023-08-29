FROM python:3.9.2

COPY ./ /opt/impulse/managerd

WORKDIR /opt/impulse/managerd

RUN pip3 install --no-cache-dir wheel

RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /opt/impulse/managerd

CMD ["./gunicorn.sh"]
