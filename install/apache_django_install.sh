#!/bin/bash

# Update and upgrade packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install openssl python3-pip apache2 libapache2-mod-wsgi-py3 virtualenv libmysqlclient-dev python-dev -y

# Move to /var/www directory
cd /var/www

# Clone the repository
git clone https://github.com/alegav1655/django_site.git

# Create a virtual environment
if ! [[ -d "django_site" ]];
	sudo mkdir django_site
fi
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
    read -p "Database Host: " db_host
    read -p "Database Port: " db_port

    # Save parameters in .env file
    echo "DATABASE_NAME=$db_name" >> .env
    echo "DATABASE_USER=$db_user" >> .env
    echo "DATABASE_PASSWORD=$db_password" >> .env
    echo "DATABASE_HOST=$db_host" >> .env
    echo "DATABASE_PORT=$db_port" >> .env
    echo "Parameters saved in the .env file!"
    sudo chmod 664 .env
fi

read -p "Do you want to setup HTTPS on Apache2? [y/n] " userReply
if [[ $userReply == "y" || $userReply == "Y" ]]; then
	
	# Run the bash script to setup HTTPS on apache2
	sudo bash https.sh
	
	# Add the wsgi configs before </VirtualHost>
	wsgi_config='\\t\tWSGIProcessGroup myapp\n\t\tWSGIScriptAlias / /var/www/django_site/mysite/wsgi.py\n\n\t\t<Directory /var/www/django_site/myapp>\n\t\t\tRequire all granted\n\t\t</Directory>\n\n\t\tAlias /static/ /var/www/django_site/myapp/static/\n\t\t<Directory /static/>\n\t\t\tRequire all granted\n\t\t</Directory>\n'
	sed -i '/<\/VirtualHost>/i '"$wsgi_config"'' "$apacheConfig"
fi

# Configure Apache
cat apache_config/add_apache2.conf >> /etc/apache2/apache2.conf
sudo a2enmod wsgi
sudo systemctl restart apache2

# Set up database
python3 manage.py makemigrations myapp
python3 manage.py migrate

echo "Installation complete! The Django project is now set up and configured with Apache."

# Exit with status code 0 (success)
exit 0
