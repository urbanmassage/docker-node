FROM gliderlabs/alpine:3.2

ENV NODE_VERSION=0.10.44 CMD=node DOMAIN=nodejs.org CFLAGS="-D__USE_MISC"

RUN apk-install openssl ca-certificates git curl make gcc g++ python linux-headers paxctl libgcc libstdc++ && \
  update-ca-certificates && \
  curl -sSL https://${DOMAIN}/dist/v${NODE_VERSION}/${CMD}-v${NODE_VERSION}.tar.gz | tar -xz && \
  cd /${CMD}-v${NODE_VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/${CMD} && \
  cd / && \
  if [ -x /usr/bin/npm -a -z "$NO_NPM_UPDATE" ]; then \
    npm install -g npm@2 && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  rm -rf /etc/ssl /${CMD}-v${NODE_VERSION} ${RM_DIRS} \
    /usr/share/man /tmp/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html

# define how to run the image
CMD [ "node" ]
