FROM centos:8 as magento

COPY ./preinstall.sh /scripts/
ADD conf/supervisord.conf /etc/supervisord.conf

RUN echo "Install ZIP Install scripts"; \
pwd && bash /scripts/preinstall.sh; \
cd ~; \
wget https://github.com/Genaker/Magento-AWS-Linux-2-Installation/archive/refs/heads/master.zip; \
unzip master.zip && cd ./Magento-AWS-Linux-2-Installation-master/; \
yum clean all; \
rm -rf /var/cache/yum; 

RUN echo "Prepare & Supervisor"; \
set -x; \
cd ~; \
cd ./Magento-AWS-Linux-2-Installation-master/; \
ls; \
echo "Installing Utilities \n"; \
bash ./install-prepare.sh; \ 
echo "Install SupervisorDd";\
yum install epel-release -y;\
yum install supervisor -y; \
yum clean all; \
rm -rf /var/cache/yum; 

RUN echo "Install PHP \n"; \
pwd; \
cd ~; \
ls; \
cd ./Magento-AWS-Linux-2-Installation-master/; \
bash ./install-php.sh; \
bash ./configure-php.sh; \
yum install php-fpm -y; \
set +e; \
bash ./install-composer.sh; \
composer clear-cache; \
set -e; \
echo "Install NGINX \n"; \
bash ./install-nginx.sh; \
echo "Configure Nginx \n"; \
set +e; \
bash ./configure-nginx.sh; \
set -e; \
yum clean all; \
rm -rf /var/cache/yum;


RUN echo "Install Magento Git \n"; \
mkdir -p /var/www/html/magento/; \
export IP=127.0.0.1; \
set +e; \
cd /var/www/html/magento/; \
git clone --depth 1 https://github.com/magento/magento2.git .; \
composer install; \
composer clearcache; \
set -e; \
yum install php-fpm -y; \
mkdir -p /run/php-fpm/; \
touch /run/php-fpm/www.sock;

ENV DOCKER=YES
EXPOSE 80 8080 443
VOLUME ["/var/www/html/shared"]
# VOLUME ["/var/www/html/magento/pub/media"]

# ENTRYPOINT ["/usr/sbin/init"]
# CMD ["/usr/bin/supervisord -n -c /etc/supervisord.conf"]
ENTRYPOINT /usr/bin/supervisord -n -c /etc/supervisord.conf
