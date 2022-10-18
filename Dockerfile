FROM ghcr.io/linuxserver/baseimage-rdesktop:arch-dbus-latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG XFCE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    firefox \
    mousepad \
    pavucontrol \
    xfce4 \
    xfce4-pulseaudio-plugin && \
  echo "**** cleanup ****" && \
  pacman -Rns --noconfirm -dd \
    xfce4-power-manager && \
  rm -rf \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3389
VOLUME /config
