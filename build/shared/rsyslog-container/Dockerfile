#
# Dockerfile for rsyslog
#

FROM alpine
MAINTAINER impulse

RUN apk add --no-cache rsyslog rsyslog-pgsql rsyslog-mysql rsyslog-tls rsyslog-relp rsyslog-mmjsonparse rsyslog-mmutf8fix tzdata

#COPY rsyslog.conf /etc/rsyslog.conf

VOLUME /var/log
WORKDIR /var/log

ENV TZ=UTC

EXPOSE 514/tcp \
       514/udp

ENTRYPOINT ["rsyslogd", "-n"]
