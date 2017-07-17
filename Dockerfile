FROM ubuntu:17.10
LABEL maintainer "Vincent Falies <vincent.falies@gmail.com>"

#------------------------------------------------
# Own build instructions
#------------------------------------------------
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#------------------------------------------------
# Netbeans 8.2 installation (PHP)
#------------------------------------------------
RUN curl -L http://download.netbeans.org/netbeans/8.2/final/bundles/netbeans-8.2-php-linux-x64.sh -o /tmp/netbeans.sh && \
    chmod +x /tmp/netbeans.sh && \
    echo 'Installing netbeans' && \
    /tmp/netbeans.sh --silent \
    rm -rf /tmp/*

ADD run /usr/local/bin/netbeans

RUN apt-get update && apt-get install -y sudo

RUN chmod +x /usr/local/bin/netbeans && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer

#------------------------------------------------
# PHP installation
#------------------------------------------------
RUN apt-get -y install php

#------------------------------------------------
# composer
#------------------------------------------------
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && chmod 755 /usr/local/bin/composer

#------------------------------------------------
# Cache clean
#------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV DEBIAN_FRONTEND dialog

ENV PATH ${HOME}/.composer/vendor/bin:${PATH}

USER developer
ENV HOME /home/developer
WORKDIR /home/developer
CMD /usr/local/bin/netbeans
