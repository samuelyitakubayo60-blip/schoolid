FROM php:8.3-apache
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev libcurl4-openssl-dev && docker-php-ext-install pdo_pgsql curl fileinfo && a2enmod rewrite headers && rm -rf /var/lib/apt/lists/*
ENV APACHE_DOCUMENT_ROOT=/var/www/html
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html && printf '<Directory /var/www/html>\nAllowOverride All\nRequire all granted\n</Directory>\n' > /etc/apache2/conf-available/app.conf && a2enconf app
EXPOSE 10000
CMD ["/bin/sh", "-c", "sed -i 's/Listen 80/Listen ${PORT:-10000}/' /etc/apache2/ports.conf && sed -i 's/:80>/:${PORT:-10000}>/' /etc/apache2/sites-available/000-default.conf && apache2-foreground"]
