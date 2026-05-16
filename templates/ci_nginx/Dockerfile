FROM jwilder/nginx-proxy:latest
COPY custom.conf /etc/nginx/conf.d/custom.conf
COPY {{PROJECT_DOMAIN}}.conf /etc/nginx/vhost.d/{{PROJECT_DOMAIN}}
