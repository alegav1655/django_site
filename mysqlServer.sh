#!/bin/bash

# Update and upgrade packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Check if MySQL is already installed
mysql &> /dev/null
if [[ $? -ne 127 ]]; then
	read -p "MySQL server is already installed, are you sure to continue? [Y/N] " reply
	if ! [[ $reply == "Y" && $reply == "y" ]]; then
		exit 1
	fi
fi
	
# Check if mysql-server or default-mysql-server (MariaDB) package is available and install it
# mysql-server has higher priority in case both are available
if [[ $(apt-cache search --names-only '^mysql-server$' | wc -l) -eq 1 ]]; then
	sudo apt install mysql-server -y
elif [[ $(apt-cache search --names-only '^default-mysql-server$' | wc -l) -eq 1 ]]; then
	sudo apt install default-mysql-server -y
else
	echo "Error, MySQL not found"
	exit 2
fi

# Set root user password to 'password'
sudo mysql --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"

# Print information about default root password
echo "+===============================================+"
echo "|                                               |"
echo "| Default root password is: password            |"
echo "| Advise: Change the default password           |"
echo "|                                               |"
echo "+===============================================+"

# Run MySQL secure installation to improve database security
sudo mysql_secure_installation

# Check MySQL version
mysql -u "root" -p --execute="SHOW VARIABLES LIKE 'version';"

# Exit with status code 0 (success)
exit 0

