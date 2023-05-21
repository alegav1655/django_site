Django Project Template

This is a Django project template that provides a simple website with user registration and login functionality, designed to be deployed with Apache and MySQL.
Full compatibility with Apache2, MySQL and Ubuntu 20.04.

Features:

- User registration and login
- Custom user model with additional "Description" field
- User profile page to view and update description

Installation for MySQL:

1. Download the bash script:

    wget https://raw.githubusercontent.com/alegav1655/django_site/main/mysqlServer.sh -q
    
    wget https://raw.githubusercontent.com/alegav1655/django_site/main/mysql_django_install.sh -q
    
2. Run the installation script as root:
    
    cd django_site/install
    
    sudo bash mysql_django_install.sh
    
    The installation script will guide you through the installation process and help you configure the MySQL DB.


Installation for the web server VM:

1. Clone the repository:

   git clone https://github.com/alegav1655/django_site.git

2. Run the installation script as root:

   sudo bash apache_django_install.sh

   The installation script will guide you through the installation process and help you configure Apache for the project.

Usage:

- Register a new user by visiting the registration page.
- Login with your credentials on the login page.
- Once logged in, you can update your description on the profile page.
