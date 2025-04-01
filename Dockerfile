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

# #  my创建 Fcitx 配置目录
# RUN mkdir -p $HOME/.config/fcitx

# #  my写入 Fcitx 配置文件，将中文输入法设置为第一个
# RUN echo -e "[Groups]\n0=fcitx-pinyin\n1=keyboard-us\n\n[GroupOrder]\n0=0\n1=1" > $HOME/.config/fcitx/profile

# #  my配置 Fcitx 开机自启
# RUN mkdir -p $HOME/.config/autostart
# RUN echo -e "[Desktop Entry]\nType=Application\nExec=fcitx -r -d\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName=fcitx\nComment=Start fcitx input method" > $HOME/.config/autostart/fcitx.desktop

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





# ports and volumes
EXPOSE 3389
VOLUME /config
