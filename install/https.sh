#!/bin/bash

# Set the public IP address of your server
PUBLIC_IP="YOUR_PUBLIC_IP_ADDRESS"

# Set the path to default-ssl.conf
SSL_CONF_PATH="/etc/apache2/sites-available/default-ssl.conf"

# Generate a private key
sudo openssl genpkey -algorithm RSA -out private.key

# Generate a Certificate Signing Request (CSR) using the IP address as the Common Name
sudo openssl req -new -key private.key -out server.csr -subj "/CN=$PUBLIC_IP"

# Generate a self-signed certificate
sudo openssl x509 -req -days 365 -in server.csr -signkey private.key -out certificate.crt

# Create a directory to store the certificate files
sudo mkdir /etc/apache2/ssl

# Move the certificate files to the appropriate directory
sudo mv private.key /etc/apache2/ssl/
sudo mv certificate.crt /etc/apache2/ssl/

# Configure Apache2 to use the SSL certificate
sudo a2enmod ssl
sudo a2ensite default-ssl.conf

# Update the default-ssl.conf file with the correct paths and IP address
sudo sed -i "s/SSLCertificateFile.*/SSLCertificateFile \/etc\/apache2\/ssl\/certificate.crt/" "$SSL_CONF_PATH"
sudo sed -i "s/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/apache2\/ssl\/private.key/" "$SSL_CONF_PATH"
sudo sed -i "s/ServerName.*/ServerName $PUBLIC_IP/" "$SSL_CONF_PATH"

# Restart Apache2 service
sudo service apache2 restart

echo "SSL certificate generated and configured successfully."

