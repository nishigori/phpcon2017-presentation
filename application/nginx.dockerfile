FROM nginx:alpine

RUN rm -f /etc/nginx/conf.d/*.conf
ADD ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
