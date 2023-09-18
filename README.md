# guacamole-compose

Docker compose project with guacamole VDI services, relying on Keycloak for authentication and user's roles

Ready in 5 minutes :)

## Configuration files

Create `.env` file in project root directory, and edit it with you own needs :

```bash
source .secrets.env
vi .env
```

### TLS server certificates

> **Please note:**  haproxy sni requires *uniq* certs for *each* backend so you'll need separate X.509 server certificates for guacamole and keycloak

You have 3 options :

- **generate self signed server certificates** : fast but dirty (on a security point of view)
  - use `TLS_LETS_ENCRYPT=false`
  - Please add init/guacamole.crt and init/keycloak.crt to your trusted certificates.

- **use free server certificates** : you need public DNS records for GUAC_HOSTNAME and KC_HOSTNAME
  - use `TLS_LETS_ENCRYPT=true`

- **generate server certificates** with your internal ca
  - use `TLS_LETS_ENCRYPT=false`
  - provide 4 files :
    - guacamole.crt
    - guacamole.key
    - keycloak.crt
    - keycloak.key

### DNS entries (or local POC settings)

As it is a web service, it requires name resolution to work : register DNS entries for keycloak or guacamole.

> add the following entry to `/etc/hosts` if you didn't register DNS entries :

```bash
source .secret.env
echo "127.0.1.1 ${GUAC_HOSTNAME} ${KC_HOSTNAME}" >>/etc/hosts
```

### finalize the configuration

the setup.sh script will configure the database and cryptographic keys 

```bash
./setup.sh
```

## Start the services

```bash
docker compose up -d
```

### Configure keycloak

This will :
1. create a new realm
2. create the guacamole client role for passing RBAC roles to guacamole 
3. create the guacadmin user and password on Keycloak  

```bash
cd config/keycloak
./1.init-keycloak-realm.sh
./2.init-keycloak-create-guacamole-admin-user.sh
```

### Configure guacamole

```bash
cd config/guacamole
./1.manage-guacamole-config.sh
```

## Using the service

Then open in your favorite browser :

- https://${GUAC_HOSTNAME}:8443/guacamole
  - authenticate with guacadmin@guacadmin + guacAdmin@guacAdmin
  - you will be prompted to change the password on first login : please store it in your favorite safe (i personally use [keepassXC](https://keepassxc.org/))
- https://${KC_HOSTNAME}:8443/admin/
  - authenticate with KEYCLOAK_ADMIN_USER + KEYCLOAK_ADMIN_PASSWORD from `.env` file

> End Users **MUST** read the end users documentation : https://guacamole.apache.org/doc/gug/using-guacamole.html

## Service administration 

In the following use case, we will add a new connection dedicated to a new user

## Adding Connections to Guacamole

---

**Upper right corner, username, settings**

![Upper right corner, username, settings](docs/images/0-guacamole-settings.png "Upper right corner, username, settings")

---

**Middle top, connections, left, new connection**

![Middle top, connections, left, new connection](docs/images/1-new-connection.png "Middle top, connections, left, new connection")

---

**Make an SSH connection**

- *Name*: some-name

- *Location*: the-group

- *Protocol*: *SSH*

- *Max number of connections*: 2

- *Max number of connections per user*: 2

Reference: https://jasoncoltrin.com/2017/10/04/setup-guacamole-remote-desktop-gateway-on-ubuntu-with-one-script/

![Protocol SSH](docs/images/2-new-connection-ssh-a.png "Protocol SSH")

---

**Set the host**

**Scroll Down**, under the Network Section set the host

![Set the host and port](docs/images/3-new-connection-ssh-b.png "Set the host and port")

**CLICK SAVE **
---

### Adding guacamole client roles to Keycloak

```bash
cd manage
./keycloak-add-gucamole-role.sh guacamoleUserGroupName "descirption of the role"
```

> the keycloak client role *guacamoleUserGroupName* must exactly match a guacamole user group

### Adding users and roles to Keycloak

```bash
cd manage
./keycloak-add-user.sh username email@fqdn
./keycloak-add-gucamole-role.sh
```

You will be prompted to select a role to the user

> if you enable MFA with X.509 certificates, the email should match the SAN extention



## Tips & tricks

### connecting to guacamole postgresql database

```bash
source .secrets.env
docker exec -it guacamole_database psql -U ${GUAC_POSTGRES_USER} -w  guacamole_db
```

## Uninstall

```
docker-compose down
./teardown.sh
```

## Features (added by Arnault MICHEL)

 - [x] use latest (@ 4 Sept 2023) versions of guacamole and keycloak software
 - [x] use a dedicated keycloak realm for guacamole (master realm should only be used for **admin purpose only**)
 - [x] add a dedicated client scope to transfer client roles in a OIDC CLAIM named [`groups`](https://guacamole.apache.org/doc/gug/openid-auth.html#configuring-guacamole-for-single-sign-on-with-openid-connect) 
 - [x] add CLI scripts to manage keycloak users and roles
 - [x] configure guacamole admin user
 - [ ] manage guacamole groups and connections with terraform 

## Reference:

  - https://github.com/airaketa/guacamole-docker-compose/tree/5aac1dccbd7b89b54330155270a4684829de1442
  - https://lemonldap-ng.org/documentation/latest/applications/guacamole
  - https://guacamole.apache.org/doc/gug/administration.html#connection-management
  - https://jasoncoltrin.com/2017/10/04/setup-guacamole-remote-desktop-gateway-on-ubuntu-with-one-script/
