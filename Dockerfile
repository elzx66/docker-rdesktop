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

RUN \
  echo "**** install packages ****" && \ 
  apt-get update && apt-get install -y wget tar unzip

# # 下载并安装 WPS Office，这里需要你手动替换为有效的下载地址
# ARG WPS_OFFICE_URL=https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/17900/wps-office_12.1.0.17900_amd64.deb?t=1743576350&k=60aea8a6ce99ea9299b44e29feb1d8d4
# RUN wget -O wps-office.deb $WPS_OFFICE_URL \
#     && dpkg -i wps-office.deb \
#     || apt-get -f install -y \
#     && rm wps-office.deb

# 写入新的 sources.list.d 文件
RUN echo 'Enabled: yes\nTypes: deb\nURIs: http://repo.debiancn.org/\nSuites: bookworm\nComponents: main\nSigned-By: /usr/share/keyrings/debiancn-keyring.gpg' > /etc/apt/sources.list.d/debiancn.sources

# 下载并安装 debiancn 密钥环
RUN wget https://repo.debiancn.org/pool/main/d/debiancn-keyring/debiancn-keyring_0~20250123_all.deb -O /tmp/debiancn-keyring.deb \
    && apt install -y /tmp/debiancn-keyring.deb \
    && apt-get update \
    && rm /tmp/debiancn-keyring.deb

# 安装 WPS Office 可能需要的额外依赖
RUN apt-get install -y \
    libglib2.0-0 \
    libxrender1 \
    libxext6 \
    libxtst6 \
    libnss3 \
    libasound2 \
    xdg-utils

# 再次更新 apt 源并安装 WPS Office
RUN apt-get update \
    && apt-get install -y wps-office \
    || { apt-get -f install -y; exit 1; }

RUN \
  cd /tmp && \
  mkdir /tmp/fonts && \
  wget -O /tmp/fonts.tar.gz -L "https://github.com/BannedPatriot/ttf-wps-fonts/archive/refs/heads/master.tar.gz" && \
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
