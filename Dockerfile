FROM nginx

COPY . /var/www/html

RUN chown www-data:www-data -R /var/www/html

EXPOSE 80

ENTRYPOINT ["tail", "-f", "/dev/null"]
