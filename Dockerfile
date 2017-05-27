FROM ubuntu:14.04
MAINTAINER billvsme "994171686@qq.com"

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y nginx
RUN apt-get install -y postgresql-9.3
RUN apt-get install -y memcached
RUN apt-get install -y python-dev python-setuptools
# RUN apt-get install -y python3
# RUN apt-get install -y python3-dev python3-setuptools
RUN apt-get install -y python-pip

RUN git clone https://github.com/billvsme/windyer_blog
WORKDIR ./windyer_blog

RUN apt-get install -y libtiff5-dev libjpeg8-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
RUN pip install -r requirements.txt
RUN apt-get install -y libpq-dev
RUN pip install psycopg2
RUN pip install gunicorn

USER postgres
RUN service postgresql start &&\
    psql --command "create user windyer with SUPERUSER password 'password';" &&\
    psql --command "create database db_windyer owner windyer;"

USER root
RUN mkdir -p /var/log/windyer
RUN service postgresql start &&\
    sleep 10 &&\
    python manage.py makemigrations --settings windyer_blog.settings_docker &&\
    python manage.py migrate --settings windyer_blog.settings_docker &&\
    echo "from windyer_auth.models import windyerUser; windyerUser.objects.create_superuser('admin', 'admin@example.com', 'password')" | python manage.py shell --settings windyer_blog.settings_docker &&\
    echo 'yes' | python manage.py collectstatic --settings windyer_blog.settings_docker

RUN ln -s /windyer_blog/nginx.conf /etc/nginx/sites-enabled/windyer
RUN rm /etc/nginx/sites-enabled/default

RUN pip install supervisor
COPY supervisord.conf /etc/supervisord.conf

RUN mkdir /var/log/supervisor

VOLUME /var/lib/postgresql/
VOLUME /var/log/windyer/

CMD supervisord -c /etc/supervisord.conf
EXPOSE 80 443
