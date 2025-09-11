# GLPI | Deployment Guide

Current version : **`10.0.16`**.

## Prerequisites and comments

The following packages are required:
- `sudo`
- `git`
- [`docker`](https://docs.docker.com/engine/install/)
- [`docker-compose`](https://docs.docker.com/compose/install/linux/)

ℹ️ **Inside the `ssl` directory**, you need `glpi.crt` and `glpi.key` files to establish an HTTPS connection for GLPI. The provided files are **self-signed**. 

You can generate and self-sign the SSL certificate with the following command:

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout ./glpi.key -out ./glpi.crt -subj "/C=FR/ST=France/L=Lyon/O=OrgVirgos/CN=glpi.local" 
```

Replace the relevant fields: `"/C=FR/ST=France/L=Lyon/O=OrgVirgos/CN=glpi.local"`

## Navigation

Choose your deployment method:
- [Manual](#manual)
- [Automatic](#automatic)

## Manual

### Deployment preparation

Retrieve the necessary files for deploying GLPI cloning this repository:

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

`secrets.env` contains the credentials used in `docker-compose.yml`:

```bash
MARIADB_ROOT_PASSWORD=<mariadb-root-password>
MARIADB_DATABASE=glpi-db
MARIADB_USER=glpi-user
MARIADB_PASSWORD=<mariadb-glpi-password>
```

**⚠️ Complete the `<mariadb-root-password>` and `<mariadb-glpi-password>` fields. ⚠️**

---

**Inside the `frontend` directory**, a configuration file `vhost_glpi.conf` is necessary for the `nginx` web server: 

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

### Deployment

To deploy GLPI, run the following script:

```bash
sudo ./deploy.sh
```

Finally, access GLPI via the URL: https://localhost

## Automatic

ℹ️ You don't need to clone the GitHub repository first, as the Ansible playbook will already be looking for it and will put it in `/opt/deploy-glpi`.

`deploy-glpi.yml`:

```yml
---
- name: Deploy GLPI
  hosts: localhost
  become: true

  vars:
    deploy_dir: /opt/deploy-glpi
    mariadb_root_password: "<mariadb-root-password>"
    mariadb_password: "<mariadb-pass>"
    domain_name: "<domain-name>"

  tasks:
    - name: Ensure required package is installed (`git`)
      become: true
      package:
        name:
          - git
        state: present
    
    - name: Remove existing GLPI repository if it exists
      file:
        path: "{{ deploy_dir }}"
        state: absent

    - name: Clone the GLPI repository
      git:
        repo: https://github.com/avirgos/deploy-glpi.git
        dest: "{{ deploy_dir }}"
        version: master
        force: no

    - name: Modify `secrets.env` file
      shell: |
        sed -i 's|<mariadb-root-password>|{{ mariadb_root_password }}|g' {{ deploy_dir }}/glpi/secrets.env
        sed -i 's|<mariadb-glpi-password>|{{ mariadb_password }}|g' {{ deploy_dir }}/glpi/secrets.env

    - name: Modify `frontend/vhost_glpi.conf` file
      shell: |
        sed -i 's|<domain-name>|{{ domain_name }}|g' {{ deploy_dir }}/glpi/frontend/vhost_glpi.conf

    - name: Execute `deploy.sh`
      become: true
      shell: |
        cd {{ deploy_dir }}/glpi && sudo ./deploy.sh
```

**⚠️ Complete the `<mariadb-root-password>`, `<mariadb-glpi-password>` and `<domain-name>` fields. ⚠️**

### Deployment

To deploy GLPI, run the following Ansible playbook:

```bash
ansible-playbook deploy-glpi.yml --ask-become-pass -v
```

- `--ask-become-pass`: requests the password of the user running the Ansible playbook to obtain super-user privileges
- `-v`: verbose mode

Finally, access GLPI via the URL: https://localhost

## Installation 

Please refer to the [installation guide](docs/INSTALL.md).
