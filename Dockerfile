FROM nginx

COPY . /usr/share/nginx/html

RUN chown www-data:www-data -R /usr/share/nginx/html/

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]

