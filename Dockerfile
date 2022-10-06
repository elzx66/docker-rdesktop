FROM ghcr.io/linuxserver/baseimage-rdesktop:fedora

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
  echo "**** install packages ****" && \
  dnf install -y --setopt=install_weak_deps=False --best \
    breeze-icon-theme \
    dolphin \
    firefox \
    kate \
    kde-gtk-config \
    kde-settings-pulseaudio \
    khotkeys \
    kmenuedit \
    konsole5 \
    plasma-breeze \
    plasma-desktop \
    plasma-discover \
    plasma-workspace-xorg && \
  echo "**** cleanup ****" && \
  dnf autoremove -y && \
  dnf clean all && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3389
VOLUME /config
