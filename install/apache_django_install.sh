#!/bin/bash

# Set installation path
myPath=$(pwd)

# Set the public IP address of your server
PUBLIC_IP="$(curl -s https://ifconfig.me)"

# Update and upgrade packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install openssl mysql-client python3-pip apache2 libapache2-mod-wsgi-py3 virtualenv libmysqlclient-dev python-dev -y

# Move to /var/www directory
cd /var/www

# Move django_site from home to var/www
if ! [[ -d "django_site" ]]; then
	sudo mv "$myPath/../django_site" "/var/www"
fi

# Create a virtual environment
cd django_site
virtualenv venv
source venv/bin/activate

# Install Python dependencies
pip3 install -r requirements.txt

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Enter the following MySQL database parameters:"
    read -p "Database Name: " db_name
    read -p "Database User: " db_user
    read -s -p "Database Password: " db_password
    echo
    read -p "Database Host IP: " db_host
    read -p "Database Port (default: 3306): " db_port

    # Save parameters in .env file
    echo "DATABASE_NAME=$db_name" >> .env
    echo "DATABASE_USER=$db_user" >> .env
    echo "DATABASE_PASSWORD=$db_password" >> .env
    echo "DATABASE_HOST=$db_host" >> .env
    echo "DATABASE_PORT=$db_port" >> .env
    echo "SECRET_KEY=" >> .env
    python3 manage.py changesecurekey
    echo "Parameters saved in the .env file!"
    sudo chmod 664 .env
fi

read -p "Do you want to setup HTTPS on Apache2? [y/n] " userReply
if [[ $userReply == "y" || $userReply == "Y" ]]; then
	# Set the path to default-ssl.conf
	SSL_CONF_PATH="/etc/apache2/sites-available/default-ssl.conf"
	
	# Run the bash script to setup HTTPS on apache2
	sudo bash "$myPath/https.sh"
	
	# Add the wsgi configs before </VirtualHost>
	wsgi_config='\\t\tWSGIProcessGroup myapp\n\t\tWSGIScriptAlias / /var/www/django_site/mysite/wsgi.py\n\n\t\t<Directory /var/www/django_site/myapp>\n\t\t\tRequire all granted\n\t\t</Directory>\n\n\t\tAlias /static/ /var/www/django_site/myapp/static/\n\t\t<Directory /static/>\n\t\t\tRequire all granted\n\t\t</Directory>\n\t\t<Directory /var/www/django_site/mysite>\n\t\t\t\t<Files wsgi.py>\n\t\t\t\t\t\tRequire all granted\n\t\t\t\t</Files>\n\t\t</Directory>'
	sudo sed -i '/<\/VirtualHost>/i '"$wsgi_config"'' "$SSL_CONF_PATH"
fi

# Configure Apache HTTP
APACHE_CONFIG="/etc/apache2/apache2.conf"
if grep -q "<VirtualHost " $APACHE_CONFIG; then
	echo "VirtualHost already exists"
else
	sudo chmod 777 $APACHE_CONFIG
	echo -e "<VirtualHost *:80>\n\tServerName localhost\n\tWSGIDaemonProcess myapp python-home=/var/www/django_site/venv python-path=/var/www/django_site\n\tWSGIProcessGroup myapp\n\tWSGIScriptAlias / /var/www/django_site/mysite/wsgi.py\n\n\t<Directory /var/www/django_site/myapp>\n\t\t Require all granted\n\t</Directory>\n\n\tAlias /static/ /var/www/django_site/myapp/static/\n\t<Directory /static/>\n\t\t Require all granted\n\t</Directory>\n</VirtualHost>" >> $APACHE_CONFIG
	sudo chmod 644 $APACHE_CONFIG
	sudo sed -i "s/ServerName.*/ServerName $PUBLIC_IP/g" "$APACHE_CONFIG"
	sudo a2enmod wsgi
	sudo systemctl restart apache2
fi

sudo systemctl restart apache2

# Set up database
python3 manage.py makemigrations myapp
python3 manage.py migrate

echo "Installation complete! The Django project is now set up and configured with Apache."

# Exit with status code 0 (success)
exit 0
