FROM alpine

RUN apk --no-cache add openssh bash

ADD ./tinker-php /usr/local/bin/php
ADD ./docker-entrypoint /docker-entrypoint

ENTRYPOINT ["/docker-entrypoint"]

