# On se base sur l'image Ubuntu 20.04
FROM ubuntu:20.04

# On désactive l'invite lors de l'installation des packages
ARG DEBIAN_FRONTEND=noninteractive

# On met à jour et on upgrade
RUN apt update && apt upgrade -y

# On installe les paquets initiaux pour PHP
RUN apt install ca-certificates apt-transport-https software-properties-common lsb-release -y

# On ajoute le repository de PHP
RUN add-apt-repository ppa:ondrej/php -y

# On met à jour le cache des packages et on upgrade
RUN apt update && apt upgrade -y

# On installe NGINX et on supprime le cache de tous les packages
RUN apt install nginx supervisor php8.3 php8.3-fpm php8.3-cli -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# On définit les variables d'environnement
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/8.3/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# On active PHP-FPM sur la configuration du virtualhost NGINX
COPY ./conf/default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}

# On copie la configuration du superviseur
COPY ./conf/supervisord.conf ${supervisor_conf}

# On créé un nouveau répertoire pour le fichier sock de PHP-FPM
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

# On définit le volume de l'image
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# On copie le fichier start.sh et on définit la commande par défaut
COPY start.sh /start.sh
CMD ["./start.sh"]

# On expose les ports
EXPOSE 443 80