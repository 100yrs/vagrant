#!/usr/bin/env bash

# Install ElasticSearch
echo ">>> Installing Elasticsearch 2.0"

# install openjdk-7 
sudo apt-get purge openjdk*
sudo apt-get -y install openjdk-7-jre

# Install elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
curl -L -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.2.0.deb
sudo apt-get update
sudo dpkg -i elasticsearch-2.2.0.deb

# Add as service
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch start

# Access "localhost:9200" from the host os
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# Enable cors (to be able to use Sense)
sudo echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "http.cors.allow-origin: /https?:\/\/.*/" >> /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch restart