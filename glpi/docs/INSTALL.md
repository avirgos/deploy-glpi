# GLPI | Installation Guide

Choose your language and click the “**OK**” button :

![install-1.png](assets/install-1.png)

Please accept the license agreement by clicking the “**Continue**” button :

![install-2.png](assets/install-2.png)

Click the “**Install**” button :

![install-3.png](assets/install-3.png)

You should see a fully compatible environment for the installation and execution of GLPI. Click the “**Continue**” button :

![install-4.png](assets/install-4.png)
![install-5.png](assets/install-5.png)

Set up the connection to the MariaDB database by entering the credentials from the `MARIADB_USER` and `MARIADB_PASSWORD` fields in `secrets.env`, then click the “**Continue**” button :

![install-6.png](assets/install-6.png)

Select the MariaDB database specified in `secrets.env` (`glpi-db`) to initialize the database :

![install-7.png](assets/install-7.png)

Finally, here is the last screen indicating the installation is complete. Click “**Use GLPI**” to proceed with the configuration of the tool :

![install-9.png](assets/install-8.png)

## Configuration 

Please refer to the [configuration guide](CONFIG.md).