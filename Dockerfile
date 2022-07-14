FROM nginx

COPY . /usr/share/nginx/html/

RUN chown www-data:www-data -R /usr/share/nginx/html/

EXPOSE 80

RUN service nginx start

ENTRYPOINT ["tail", "-f", "/dev/null"]
