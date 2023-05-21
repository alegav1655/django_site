#!/bin/bash

is_private() {
	local IFS='.'
	read -ra octets <<< "$1"
	local octet1=${octets[0]}
	local octet2=${octets[1]}
	
	# Check if the IP address matches any private IP ranges
	if [[ $octet1 == "10" ]] ||
		 [[ $octet1 == "172" && ($octet2 -ge 16 && $octet2 -le 31) ]] ||
		 [[ $octet1 == "192" && $octet2 == "168" ]]; then
		return 0
	else
		return 1
	fi
}

# Run mysql installation file
if [[ -f "mysqlServer.sh" ]]; then
	bash mysqlServer.sh
else
	echo "mysqlServer.sh file not found!"
	exit 1
fi

# Get parameters that are going to be used for the Django database
echo "Enter the following MySQL database parameters: database name, user and password"
read -p "New database name: " db_name
read -p "New user: " db_user
read -s -p "New password for $db_user: " db_password
echo

# Ask the user the IP
read -p "Enter the LAN IP of the web server: " lan_ip

# Check if is a valid IP
if is_private "$lan_ip"; then
  echo "$lan_ip is a valid private IP address."
else
  echo "$lan_ip is not a valid private IP address."
  exit 1
fi

# Let other IPs access the DB
sed -i 's/^\(bind-address\|mysqlx-bind-address\)/# \1/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo "Insert root password: "
# Create the user and database if they don't exist, grant and update privileges
mysql -u "root" -p -e "CREATE USER IF NOT EXISTS '$db_user'@'$lan_ip' IDENTIFIED BY '$db_password'; CREATE DATABASE IF NOT EXISTS $db_name; GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'$lan_ip'; FLUSH PRIVILEGES;"

# Restart MySQL server
sudo systemctl restart mysql

echo "MySQL server is now ready! Install Django on the other VM!"

# Exit with status code 0 (success)
exit 0

