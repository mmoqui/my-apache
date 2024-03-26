FROM debian:bookworm-slim

MAINTAINER Miguel Moquillon "miguel.moquillon@gmail.com"
LABEL name="My Apache Distribution" description="My own custom Apache2 to serves my applications"

ARG DEFAULT_LOCALE=fr_FR.UTF-8
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV TERM=xterm
ENV TZ=Europe/Paris
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked apt-get update \
	&& apt-get install -y tzdata \
	&& apt-get install -y --no-install-recommends locales \
      curl \
    	psmisc \
		  iputils-ping \
    	vim \
    	procps \
    	net-tools \
      gnupg \
    	zip \
    	unzip \
      bzip2 \
      openssl \
    	ca-certificates \
    	apache2 \
      libapache2-mod-php \
      php-curl \
      php-mbstring \
      php-xml \
      php-zip \
      php-imagick

RUN set -e; \
    update-ca-certificates -f; \
    echo "${DEFAULT_LOCALE} UTF-8" >> /etc/locale.gen; \
    locale-gen; \
    update-locale LANG=${DEFAULT_LOCALE} LANGUAGE=${DEFAULT_LOCALE} LC_ALL=${DEFAULT_LOCALE}; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
    groupadd -g ${GROUP_ID} mygroup; \
    useradd -u ${USER_ID} -g ${GROUP_ID} -G users \
        -d /home/myuser -s /bin/bash -m myuser;

ENV LANG ${DEFAULT_LOCALE}
ENV LANGUAGE ${DEFAULT_LOCALE}
ENV LC_ALL ${DEFAULT_LOCALE}

COPY src/inputrc /root/.inputrc
COPY --chown=${USER_ID}:${GROUP_ID} src/inputrc /home/myuser/.inputrc
COPY src/mywebapp.conf /etc/apache2/sites-available/
COPY src/run.sh /usr/local/bin/

RUN a2enmod proxy proxy_http rewrite headers reqtimeout http2 \
    && a2dissite 000-default.conf default-ssl.conf \
    && a2ensite mywebapp.conf

WORKDIR /home/myuser

VOLUME ["/home/myuser", "/var/log/apache2"]

EXPOSE 80 443

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/usr/local/bin/run.sh"]
