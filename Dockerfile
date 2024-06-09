# Usa la imagen base de Debian 12 #
FROM debian:12

# Mantenedor de la imagen #
MAINTAINER raul rodriguez <ra.rodriguezs@duocuc.cl>

# Establece variables de entorno #
ENV NAGIOS_HOME /usr/local/nagios
ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios1
ENV NAGIOS_CMDUSER nagios
ENV NAGIOS_CMDGROUP nagioscmd
ENV NAGIOSADMIN_USER raul
ENV NAGIOSADMIN_PASS andres
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

# Actualiza el sistema e instala lo necesario #
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    gcc \
    libc6 \
    make \
    wget \
    unzip \
    apache2 \
    apache2-utils \
    php \
    libgd-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario y grupo de Nagios #
RUN useradd ${NAGIOS_USER} \
    && groupadd ${NAGIOS_GROUP} \
    && groupadd ${NAGIOS_CMDGROUP} \
    && usermod -a -G ${NAGIOS_CMDGROUP} ${NAGIOS_USER} \
    && usermod -a -G ${NAGIOS_CMDGROUP} ${APACHE_RUN_USER}

# Actualizar certificados CA #
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates

# Descargar e instalar Nagios Core #
RUN cd /tmp \
    && wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.6/nagios-4.4.6.tar.gz \
    && tar -zxvf nagios-4.4.6.tar.gz \
    && cd nagios-4.4.6 \
    && ./configure --with-command-group=${NAGIOS_CMDGROUP} \
    && make all \
    && make install \
    && make install-commandmode \
    && make install-init \
    && make install-config \
    && make install-webconf \
    && a2enmod rewrite \
    && a2enmod cgi

# Configurar el usuario de Nagios para la interfaz web #
RUN htpasswd -bc ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS}

# Descargar e instalar los plugins de Nagios #
RUN cd /tmp \
    && wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz \
    && tar -zxvf nagios-plugins-2.3.3.tar.gz \
    && cd nagios-plugins-2.3.3 \
    && ./configure --with-nagios-user=${NAGIOS_USER} --with-nagios-group=${NAGIOS_GROUP} --with-openssl \
    && make \
    && make install

# Configurar Apache para que Nagios sea el índice predeterminado #
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && echo "<Directory /usr/local/nagios/share>" > /etc/apache2/conf-available/nagios.conf \
    && echo "    Options None" >> /etc/apache2/conf-available/nagios.conf \
    && echo "    AllowOverride None" >> /etc/apache2/conf-available/nagios.conf \
    && echo "    Require all granted" >> /etc/apache2/conf-available/nagios.conf \
    && echo "</Directory>" >> /etc/apache2/conf-available/nagios.conf \
    && a2enconf nagios \
    && echo "DocumentRoot /usr/local/nagios/share" > /etc/apache2/sites-available/000-default.conf \
    && echo "<Directory /usr/local/nagios/share>" >> /etc/apache2/sites-available/000-default.conf \
    && echo "    Options None" >> /etc/apache2/sites-available/000-default.conf \
    && echo "    AllowOverride None" >> /etc/apache2/sites-available/000-default.conf \
    && echo "    Require all granted" >> /etc/apache2/sites-available/000-default.conf \
    && echo "</Directory>" >> /etc/apache2/sites-available/000-default.conf

# Exponer puertos necesarios (apache y nagios)  #
EXPOSE 80 5667

# Copiar y configurar el script de inicio #
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Establecer el punto de entrada #
CMD ["/usr/local/bin/start.sh"]
