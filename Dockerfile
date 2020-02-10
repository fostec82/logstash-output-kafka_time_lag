FROM ubuntu
RUN apt-get -y update
RUN apt-get -y install default-jdk
RUN apt-get -y install apt-transport-https wget gnupg2
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get -u update && \
  apt-get install -y \
  logstash \
  nano \
  vim
