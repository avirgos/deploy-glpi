# GLPI | Deployment Guide

## Prerequisites

Commands have been executed on **Debian 12 (bookworm)**. A GNU/Linux system is required.

### | Git |

```
sudo apt-get install git
```

### | Docker |

```bash
# add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### | Docker Compose |

```bash
sudo apt-get install docker-compose
```

## Deployment Preparation

Retrieve the necessary files for deploying GLPI cloning this repository :

```bash
git clone https://github.com/avirgos/deploy-glpi.git
```

Here’s the structure of the `glpi` directory:

```bash
├── deploy.sh
├── docker-compose.yml
├── frontend
│   └── vhost_glpi.conf
├── scripts
│   └── glpi-setup.sh
├── secrets.env
└── ssl
    ├── glpi.crt
    └── glpi.key
```

---

`secrets.env` contains the credentials used in `docker-compose.yml` :

```bash
MARIADB_ROOT_PASSWORD=<mariadb-root-password>
MARIADB_DATABASE=glpi-db
MARIADB_USER=glpi-user
MARIADB_PASSWORD=<mariadb-glpi-password>
```

**⚠️ Complete the `<mariadb-root-password>` and `<mariadb-glpi-password>` fields. ⚠️**

---

**Inside the `frontend` directory**, a configuration file `vhost_glpi.conf`, necessary for the `nginx` web server, can be found : 

```nginx
server {
    listen 443 ssl;
    server_name <domain-name>;
    
    root /var/www/glpi/public;

    ssl_certificate /etc/ssl/glpi.crt;     
    ssl_certificate_key /etc/ssl/glpi.key;
    
    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        
    fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

**⚠️ Complete the `<domain-name>` field. ⚠️**

---

**Inside the `ssl` directory**, you need `glpi.crt` and `glpi.key` files to establish an HTTPS connection for GLPI. The provided files are **self-signed**.

You can generate and self-sign the SSL certificate with the following command :

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout ./glpi.key -out ./glpi.crt -subj "/C=FR/ST=France/L=Lyon/O=OrgVirgos/CN=glpi.local" 
```

Replace the relevant fields : `"/C=FR/ST=France/L=Lyon/O=OrgVirgos/CN=glpi.local"` 

## Deployment

To deploy GLPI, run the following script :

```bash
sudo ./deploy.sh
```

Finally, access GLPI via the URL : [https://localhost](https://localhost/).

## Installation 

Please refer to the [installation guide](docs/INSTALL.md).