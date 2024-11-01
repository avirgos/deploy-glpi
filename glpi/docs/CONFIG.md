# GLPI | Configuration Guide

## First Login

Log in with the administrator account `glpi/glpi` :

![config-1.png](assets/config-1.png)

### Security Warnings

Upon accessing the admin interface, you may see a security warning recommending you change the passwords for the `glpi`, `post-only`, `tech` and `normal` accounts :

![config-2.png](assets/config-2.png)

In this example, we will change the password for the `glpi` account. To do so, go to the “**Administration**” > “**Users**”. Then, click on the user whose password needs to be changed, fill in the following fields, and click the “**Save**” button to apply the changes :

![config-3](assets/config-3.png)

Repeat this process for the `post-only`, `tech` and `normal` accounts.

The second security warning indicates that the `install/install.php` file is present and should be removed :

![config-4](assets/config-4.png)

To remove it, rerun the following script :

```bash
sudo ./deploy.sh
```

## Backup

To backup the MariaDB database as well as GLPI data, run the following script **from the GLPI directory** :

```bash
sudo ./scripts/backup.sh
```

After running the script, in the `backups/` directory, you will find :

- `db-backup-YYYY-MM-DD.sql` : backup file of the MariaDB database
- `glpi-backup-YYYY-DD-MM` : directory containing the backup of GLPI data

```bash
.
├── db-backup-YYYY-MM-DD.sql
└── glpi-backup-YYYY-DD-MM
```