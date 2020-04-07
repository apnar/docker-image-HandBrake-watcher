FROM ubuntu:bionic
MAINTAINER Josh Lukens <jlukens@botch.com>

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN echo 'deb http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu bionic main' > /etc/apt/sources.list.d/handbrake.list && \
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 816950D8 && \
        apt-get update && \
	apt-get -y install handbrake-cli task-spooler inotify-tools wget apt-transport-https ca-certificates && \
        wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
        echo 'deb https://mkvtoolnix.download/ubuntu/ bionic main' > /etc/apt/sources.list.d/bunkus.org.list && \
        apt-get update && \
        apt-get -y install mkvtoolnix && \
	apt-get clean && \
        rm -rf /var/lib/apt/lists/* 

VOLUME /watch
VOLUME /output

COPY Uconnect.json /Uconnect.json
COPY entrypoint.sh /entrypoint.sh
COPY rip_dvd /rip_dvd
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

