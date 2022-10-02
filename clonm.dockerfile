FROM clonm/postfix

VOLUME /etc/sympa/shared

RUN apt-get update -q -q && \
 apt-get install adduser openssh-client sasl2-bin libsasl2-2 libsasl2-modules --yes --force-yes && \
 adduser --system --group mailpipe --no-create-home --home /nonexistent && \
 cp /etc/postfix/main.cf /etc/postfix/main.cf.orig && \
 cp /etc/postfix/master.cf /etc/postfix/master.cf.orig

COPY ./etc /etc
COPY /etc/postfix/sasl/smtpd.conf /usr/lib/sasl2/smptd.conf
RUN sed -i 's/START=no/START=yes/' /etc/default/saslauthd && \
 sed -i 's/MECHANISMS="pam"/MECHANISMS="sasldb"/' /etc/default/saslauthd && \
 service saslauthd start
