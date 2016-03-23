#!/usr/bin/env bash

# Install ElasticSearch
echo ">>> Installing Elasticsearch 2.2"


# install Java, remove openjdk if present.
sudo apt-get purge openjdk*
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update -qq
sudo apt-get -y install oracle-java8-installer

if which java >/dev/null; then
    echo ">>> Java already installed. Skip."
else
    echo ">>> Install Java 8"
    add-apt-repository ppa:webupd8team/java
    apt-get update -qq
    echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections
    apt-get install --yes oracle-java8-installer
    yes "" | apt-get -f install
fi


# Install elasticsearch
echo ">>> Install Elastcisearch 2.2"
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
curl -L -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.2.0.deb
sudo dpkg -i elasticsearch-2.2.0.deb

# Add as service
echo ">>> Configure Elasticsearch as service"
sudo update-rc.d elasticsearch defaults 95 10
sudo service elasticsearch start

# Access "localhost:9200" from the host os
sudo grep -q -F 'network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml || echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# Enable cors (to be able to use Sense)
sudo grep -q -F 'http.cors.enabled: true' /etc/elasticsearch/elasticsearch.yml || echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo grep -q -F 'http.cors.allow-origin: /https?:\/\/.*/' /etc/elasticsearch/elasticsearch.yml || echo "http.cors.allow-origin: /https?:\/\/.*/" >> /etc/elasticsearch/elasticsearch.yml

echo ">>> Restart Elasticsearch"
sudo service elasticsearch restart