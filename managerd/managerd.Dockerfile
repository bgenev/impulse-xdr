FROM python:3.9.2

#COPY ./ /opt/impulse/managerd

RUN mkdir -p /opt/impulse/managerd
COPY ./requirements.txt /opt/impulse/managerd/requirements.txt
COPY ./gunicorn.sh /opt/impulse/managerd/gunicorn.sh

WORKDIR /opt/impulse/managerd

RUN pip3 install --no-cache-dir wheel

RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /opt/impulse/managerd

CMD ["./gunicorn.sh"]
