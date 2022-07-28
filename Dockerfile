FROM nginx

RUN apt-get update && \
    apt-get upgrade -y

COPY html/ /usr/share/nginx/html

COPY default.conf /etc/nginx/conf.d/default.conf

RUN chown www-data:www-data -R /usr/share/nginx/html/

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]

