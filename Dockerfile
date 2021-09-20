FROM centos:7
RUN yum install -y epel-release && \
    yum install -y nginx

COPY index.html /usr/share/nginx/html
COPY ./images/fire-icon.jpg /usr/share/nginx/images/fire-icon.jpg
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
CMD /usr/sbin/nginx -g 'daemon off;'