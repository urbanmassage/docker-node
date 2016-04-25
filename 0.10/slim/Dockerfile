FROM progrium/busybox

ENV NODE_VERSION 0.10.44

# install nodejs and all deps
ENV CMD=node DOMAIN=nodejs.org
RUN \
  opkg-install curl bash git libstdcpp && \
  rm -f /lib/libpthread.so.0 && \
  ln -s /lib/libpthread-2.18.so /lib/libpthread.so.0 && \
  curl -s https://${DOMAIN}/dist/v${NODE_VERSION}/${CMD}-v${NODE_VERSION}-linux-x64.tar.gz | gunzip | tar -xf - -C /

ENV PATH /${CMD}-v${NODE_VERSION}-linux-x64/bin:$PATH
RUN npm install -g npm@2

# define how to run the image
CMD [ "node" ]
