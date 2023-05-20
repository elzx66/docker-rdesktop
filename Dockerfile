FROM ghcr.io/linuxserver/baseimage-rdesktop:arch-dbus

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"


RUN \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    chromium \
    openbox \
    obconf-qt \
    xfce4-terminal && \
  echo "**** application tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  ln -s \
    /usr/sbin/xfce4-terminal \
    /usr/bin/x-terminal-emulator && \
  echo "**** cleanup ****" && \
  rm -rf \
    /config/.cache \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3389
VOLUME /config
