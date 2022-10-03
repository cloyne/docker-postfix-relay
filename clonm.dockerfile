FROM clonm/postfix

VOLUME /etc/sympa/shared

RUN apt-get update -q -q && \
 apt-get install adduser openssh-client --yes --force-yes && \
 adduser --system --group mailpipe --no-create-home --home /nonexistent && \
 cp /etc/postfix/main.cf /etc/postfix/main.cf.orig && \
 cp /etc/postfix/master.cf /etc/postfix/master.cf.orig && \
 mkdir -p /etc/service

COPY ./etc/postfix /etc/postfix
COPY ./etc/service/postfix /etc/service/postfix
COPY ./etc/aliases /etc/aliases
RUN sed -i 's/smtpd_tls_session_cache_database=.*$/smtpd_tls_session_cache_database=btree:\/var\/run\/postfix\/smtpd_cache/' /etc/postfix/main.cf && \
 sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

COPY /etc/postfix/sasl/smtpd.conf /usr/lib/sasl2/smptd.conf
RUN sed -i 's/START=no/START=yes/' /etc/default/saslauthd && \
 sed -i 's/MECHANISMS="pam"/MECHANISMS="sasldb"/' /etc/default/saslauthd && \
 rm -rf /etc/sasldb2 && \
 ln -s /etc/postfix/sasl/sasldb2 /etc/sasldb2 && \
 service saslauthd start
