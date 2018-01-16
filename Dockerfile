FROM ubuntu:xenial
MAINTAINER Josh Lukens <jlukens@botch.com>

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository ppa:stebbins/handbrake-releases && \
        apt-get update && \
	apt-get -y install handbrake-cli && \
	apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \

VOLUME /input
VOLUME /output

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

