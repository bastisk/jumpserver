# Dockerfile for a Jumpserver
# ================================================================
# File created by: Sebastian Kiepsch
# Procedure:
#	1. Install Nginx, shellinabox & openssl, supervisor
#   2. Create self signed Certificate
#   5. Configure System

FROM ubuntu:14.04
MAINTAINER Sebastian Kiepsch <basti.sk@gmx.de>

ENV username test
ENV password test

ENV DEBIAN_FRONTEND noninteractive
RUN groupadd -r shellinabox && useradd -r -g shellinabox shellinabox
RUN mkdir -p /home/docker
RUN /usr/sbin/useradd docker -g sudo
RUN echo "docker:docker" | /usr/sbin/chpasswd

# Install Software
RUN apt-get update -y && apt-get install -y nginx apache2-utils openssl shellinabox supervisor
RUN mkdir -p  /var/run/sshd /var/run/nginx /var/run/shellinabox /var/log/supervisor

# Create Password File from given Variables
RUN htpasswd -b -c /etc/nginx/.htpasswd ${username} ${password}

# Generate Certificate
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=/ST=/L=/O=/CN=host"
RUN cat /etc/nginx/ssl/nginx.crt /etc/nginx/ssl/nginx.key > /etc/nginx/ssl/nginx.pem

# Copy Configuration Files
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./default /etc/nginx/sites-available/default
ADD ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 22 80 443 4200
CMD ["/usr/bin/supervisord"]
