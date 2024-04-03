FROM ubuntu:16.04
## https://itgovernanceportal.com/otrs/otrs-znuny-ubuntu-nginx/?cn-reloaded=1
## https://gist.github.com/ngi/c314079f11238d63488302d92a412344

# docker build --no-cache -t jniltinho/otrs-server .
# docker run -d --name otrs-server -p 8080:80 jniltinho/otrs-server

RUN apt-get update && apt-get install -y nginx spawn-fcgi fcgiwrap cron \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl \
    libsoap-lite-perl libgd-text-perl libgd-graph-perl curl wget \
    libcrypt-ssleay-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl \
    libxml-libxml-perl libxml-libxslt-perl libpdf-api2-simple-perl libauthen-ntlm-perl \
    libyaml-libyaml-perl libtemplate-perl libcrypt-eksblowfish-perl \
    libarchive-zip-perl libdbi-perl libdbd-mysql-perl libnet-dns-perl \
    libnet-dns-perl libtext-csv-xs-perl libjson-xs-perl libdatetime-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80
STOPSIGNAL SIGTERM

RUN useradd -r -d /opt/otrs -c 'OTRS User' otrs && usermod -a -G www-data otrs
COPY otrs-4.0.6.tar.gz /opt/
RUN cd /opt/ && tar -xzf otrs-4.0.6.tar.gz && mv otrs-4.0.6 otrs && chown -R otrs:otrs otrs && rm -f otrs-4.0.6.tar.gz

RUN cd /opt/otrs/var/cron && for foo in *.dist; do cp $foo `basename $foo .dist`; done
RUN cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm && /opt/otrs/bin/otrs.SetPermissions.pl --otrs-user=www-data --web-group=www-data
RUN /opt/otrs/bin/Cron.sh start otrs

RUN rm -f /etc/nginx/sites-enabled/default
COPY ./default /etc/nginx/sites-enabled/default
COPY ./fastcgi_params /etc/nginx/fastcgi_params


COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
