#!/usr/bin/env bash

VER='4.4'
HOST='kibana.hostname.local'

# Get command line arguments
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -v|--version)
    VER="$2"
    shift # past argument
    ;;
    -h|--host)
    HOST="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done


# Install Kibana
echo ">>> Installing Kibana"

echo "deb http://packages.elastic.co/kibana/${VER}/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana-$VER.x.list
sudo apt-get update
sudo apt-get -y install kibana
sudo chown -R kibana:kibana /opt/kibana

# Replace default domain with localhost
sudo sed -i s,0.0.0.0,127.0.0.1,g /opt/kibana/config/kibana.yml
sudo sed -i s,'# server.host','server.host',g /opt/kibana/config/kibana.yml

sudo update-rc.d kibana defaults 96 9
sudo service kibana start


# Install Sense
echo ">>> Installing Sense"
sudo /opt/kibana/bin/kibana plugin --install elastic/sense
sudo chmod 666 /opt/kibana/optimize/.babelcache.json
sudo service kibana restart


# Setup Proxy to allow kibana to be externally accessed
echo ">>> Enable Proxy"
sudo a2enmod proxy
sudo a2enmod proxy_balancer
sudo a2enmod proxy_http
sudo service apache2 restart


# Create virual host from passed hostname
echo ">>> Creating Kibana VirtualHost: ${HOST}"
echo "<VirtualHost *:80>
  ServerName $HOST
  ProxyRequests Off
  ProxyPass / http://127.0.0.1:5601
  ProxyPassReverse / http://127.0.0.1:5601
  RewriteEngine on
  RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  RewriteRule .* http://127.0.0.1:5601%{REQUEST_URI} [P,QSA]
</VirtualHost>" > /etc/apache2/sites-available/$HOST.conf
sudo a2ensite $HOST
sudo service apache2 restart