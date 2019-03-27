FROM budrom/rpi-php:7.0-fpm

ENV BOOKSTACK=BookStack \
    BOOKSTACK_VERSION=0.25.5 \
    BOOKSTACK_HOME="/var/www/bookstack"

RUN apt-get update && apt-get install -y unzip git zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev wget libldap2-dev nginx libtidy-dev\
   && docker-php-ext-install pdo pdo_mysql mbstring zip tidy \
   && docker-php-ext-configure ldap --with-libdir=lib/arm-linux-gnueabihf/ \
   && docker-php-ext-install ldap \
   && docker-php-ext-configure gd --with-freetype-dir=usr/include/ --with-jpeg-dir=/usr/include/ \
   && docker-php-ext-install gd \
   && cd /var/www && curl -sS https://getcomposer.org/installer | php \
   && mv /var/www/composer.phar /usr/local/bin/composer \
   && wget https://github.com/ssddanbrown/BookStack/archive/v${BOOKSTACK_VERSION}.zip -O ${BOOKSTACK}.zip \
   && unzip ${BOOKSTACK}.zip && mv BookStack-${BOOKSTACK_VERSION} ${BOOKSTACK_HOME} && rm ${BOOKSTACK}.zip  \
   && cd $BOOKSTACK_HOME/Bookstack-${BOOKSTACK_VERSION} && mv * ../ && mv -f .* ../ \
   && cd $BOOKSTACK_HOME && composer install \
   && chown -R www-data:www-data $BOOKSTACK_HOME \
   && apt-get -y autoremove \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY bookstack /etc/nginx/sites-available/bookstack
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/bookstack /etc/nginx/sites-enabled/bookstack

COPY docker-entrypoint.sh /

WORKDIR $BOOKSTACK_HOME

EXPOSE 80

VOLUME ["$BOOKSTACK_HOME/public/uploads","$BOOKSTACK_HOME/public/storage"]

ENTRYPOINT ["/docker-entrypoint.sh"]
