FROM ghcr.io/linuxserver/baseimage-rdesktop:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

#my
ENV LC_ALL=zh_CN.UTF-8

# 安装中文字体、 Fcitx 输入法框架和中文输入法
RUN apt-get update && apt-get install -y fonts-noto-cjk \
    fcitx \
    fcitx-pinyin \
    fcitx-config-gtk

# my设置输入法环境变量
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx
ENV GTK_IM_MODULE=fcitx

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends \
    chromium \
    chromium-l10n \
    dolphin \
    gwenview \
    kde-config-gtk-style \
    kdialog \
    kfind \
    khotkeys \
    kio-extras \
    knewstuff-dialog \
    konsole \
    ksystemstats \
    kwin-addons \
    kwin-x11 \
    kwrite \
    plasma-desktop \
    plasma-workspace \
    qml-module-qt-labs-platform \
    systemsettings && \
  echo "**** application tweaks ****" && \
  sed -i \
    's#^Exec=.*#Exec=/usr/local/bin/wrapped-chromium#g' \
    /usr/share/applications/chromium.desktop && \
  echo "**** kde tweaks ****" && \
  sed -i \
    's/applications:org.kde.discover.desktop,/applications:org.kde.konsole.desktop,/g' \
    /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# USER root
# 使用 im-config 初始化输入法，生成所需的$HOME/config/.xinputrc
# RUN im-config -n fcitx && \
#     cat $HOME/config/.xinputrc
# && \
#     mv ./.xinputrc $HOME/config/.xinputrc
# USER abc

# 使用 im-config 初始化输入法并添加调试信息
RUN mkdir -p /home/abc && \
    im-config -n fcitx || { echo "im-config failed"; exit 1; } && \
    ls -alh /home/abc
    # && \
    # mkdir -p $HOME/.config/xinput && \
    # mv /root/.xinputrc $HOME/.config/xinput/.xinputrc

# ports and volumes
EXPOSE 3389

VOLUME /config
