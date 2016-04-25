FROM progrium/busybox

# install nodejs and all deps
ENV VERSION=v0.10.44 CMD=node DOMAIN=nodejs.org
RUN \
  opkg-install curl bash git libstdcpp && \
  rm -f /lib/libpthread.so.0 && \
  ln -s /lib/libpthread-2.18.so /lib/libpthread.so.0 && \
  curl -s https://${DOMAIN}/dist/${VERSION}/${CMD}-${VERSION}-linux-x64.tar.gz | gunzip | tar -xf - -C /

ENV PATH /${CMD}-${VERSION}-linux-x64/bin:$PATH
RUN npm install -g npm@2

# define how to run the image
CMD [ "node" ]
