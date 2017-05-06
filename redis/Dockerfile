FROM ${base_image}

ENV REDIS_VERSION=${version}
ENV REDIS_DOWNLOAD_URL=http://download.redis.io/releases

RUN addgroup -S redis && adduser -S -G redis redis \
 && apk add --no-cache \
    ca-certificates \
    'su-exec>=0.2' \
 && apk add --no-cache --virtual .build-deps \
    curl \
    gcc \
    linux-headers \
    make \
    musl-dev \
    openssl \
 && curl -SLO "$REDIS_DOWNLOAD_URL/redis-$REDIS_VERSION.tar.gz" \
 && echo "${checksum}" | sha256sum -c - \
 && mkdir -p "/usr/src/redis" \
 && tar -xzf "redis-$REDIS_VERSION.tar.gz" -C "/usr/src/redis" --strip-components=1 \
 && rm "redis-$REDIS_VERSION.tar.gz" \
 && cd /usr/src/redis \
 && make -j$(getconf _NPROCESSORS_ONLN) \
 && make install \
 && rm -r /usr/src/redis \
 && apk del .build-deps

RUN mkdir "/data" && chown redis:redis "/data"

VOLUME "/data"
WORKDIR "/data"

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD [ "redis-server" ]
