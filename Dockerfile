FROM ghcr.io/linuxserver/baseimage-rdesktop:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

#my
ENV LC_ALL=zh_CN.UTF-8
# my设置输入法环境变量
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx
ENV GTK_IM_MODULE=fcitx

# 安装中文字体、 Fcitx 输入法框架和中文输入法。进入系统要手动激活一下：在应用程序搜索栏搜索"input"，在搜索结果中点击"Fcitx"即可，不是“Fcitx配置”
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends \
    fonts-noto-cjk \
    fcitx \
    fcitx-pinyin \
    fcitx-config-gtk

# 添加 WPS Office 的软件源
RUN echo "deb http://repo.wps.cn/ubuntu/ trusty main" > /etc/apt/sources.list.d/wps-office.list

# 安装必要的工具
RUN apt-get update && apt-get install -y wget gnupg2

# 下载 GPG 密钥并添加到 trusted.gpg.d 目录
RUN wget -q -O /usr/share/keyrings/wps-office-archive-keyring.gpg http://repo.wps.cn/ubuntu/pubkey.gpg

# 更新软件包列表并安装 WPS Office
RUN apt-get update && apt-get install -y --no-install-recommends wps-office \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN \
  cd /tmp && \
  mkdir /tmp/fonts && \
  wget -o /tmp/fonts.tar.gz -L "https://github.com/BannedPatriot/ttf-wps-fonts/archive/refs/heads/master.tar.gz" && \
  tar xf /tmp/fonts.tar.gz -C /tmp/fonts/ --strip-components=1 && \
  cd /tmp/fonts && \
  bash install.sh

RUN \
  echo "**** install pycharm community ****" && \
  wget -O pycharm.tar.gz $(wget -q -O - https://www.jetbrains.com/pycharm/download/download-thanks.html?platform=linux&code=PCC \
  | grep -oP 'https://download.jetbrains.com/python/pycharm-community-[0-9.]+.tar.gz') && \
  tar -xzf pycharm.tar.gz -C /opt && \
  rm pycharm.tar.gz && \
  ln -s /opt/pycharm-community-*/bin/pycharm.sh /usr/local/bin/pycharm

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
