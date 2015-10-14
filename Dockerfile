# Dockerfile for a Jumpserver
# ================================================================
# File created by: Sebastian Kiepsch
# Procedure:
#	1. Install Nginx, shellinabox & openssl, supervisor
#   2. Create self signed Certificate
#   5. Configure System

FROM ubuntu:14.04
MAINTAINER Sebastian Kiepsch <basti.sk@gmx.de>

ENV DEBIAN_FRONTEND noninteractive

# Install Software
RUN apt-get update -y && apt-get install -y apache2-utils openssl shellinabox supervisor
RUN mkdir -p  /var/run/sshd /var/run/nginx /var/run/shellinabox /var/log/supervisor

# Create Password File from given Variables
RUN htpasswd -b /etc/nginx/.htpasswd ${username} ${password}

# Generate Certificate
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey -subj "/C=/ST=/L=/O=/CN=" rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

# Copy Configuration Files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY default /etc/nginx/sites-available/default

EXPOSE 22 443
CMD ["/usr/bin/supervisord"]