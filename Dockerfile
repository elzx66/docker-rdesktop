FROM ghcr.io/linuxserver/baseimage-rdesktop:alpine320

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ICEWM_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"


RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    firefox \
    icewm \
    st \
    util-linux-misc && \
  echo "**** application tweaks ****" && \
  ln -s \
    /usr/bin/st \
    /usr/bin/x-terminal-emulator && \
  rm /usr/bin/xterm && \
  ln -s \
    /usr/bin/st \
    /usr/bin/xterm && \
  echo "**** theme ****" && \
  rm -Rf /usr/share/icewm/themes/default && \
  curl -s \
    http://ryankuba.com/ice.tar.gz \
    | tar zxf - -C /usr/share/icewm/themes/ && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3389

VOLUME /config
