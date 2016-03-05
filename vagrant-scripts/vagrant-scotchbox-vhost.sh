#!/usr/bin/env bash

DOMAIN='scotchbox.local'
WEBROOT='/var/www/public'

# Get command line arguments
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -d|--domain)
    DOMAIN="$2"
    shift # past argument
    ;;
    -w|--webroot)
    WEBROOT="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

echo "Copying vhost config for ${DOMAIN} at ${WEBROOT} from template..."
sudo cp /etc/apache2/sites-available/scotchbox.local.conf /etc/apache2/sites-available/$DOMAIN.conf
echo "Updating vhost config template for ${DOMAIN}..."
sudo sed -i s,scotchbox.local,$DOMAIN,g /etc/apache2/sites-available/$DOMAIN.conf
sudo sed -i s,/var/www/public,$WEBROOT,g /etc/apache2/sites-available/$DOMAIN.conf
echo "Enabling ${DOMAIN}."
sudo a2ensite $DOMAIN.conf
echo "Disable default sites..."
sudo a2dissite 000-default
sudo a2dissite scotchbox.local
echo "Restarting apache"
sudo service apache2 restart