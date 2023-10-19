easy RSA can help you to :
1. create a dedicated private CA
2. issue client certificates for authentication

# install easy rsa

- on  Centos / Rocky Linux / RHEL : `sudo yum install easy-rsa`
- on debian / Ubuntu : `sudo apt install easy-rsa`
- on Gentoo : `sudo emerge -qavt app-crypt/easy-rsa`

# Customize easyRSA 

edit `.env` to feet your needs, according to the [documentation](https://easy-rsa.readthedocs.io/en/latest/advanced/#environmental-variables-reference)

# create your private CA

```bash
EASYRSA_VARS_FILE=.env
easyrsa init-pki
easyrsa build-ca
cp pki/ca.crt ../trustedCAs/
```

# generate end user certificate for authentication

this example generate a certificate for the sample user defined in `config/keycloak/guacamole-realm-config/users.tf` :

```bash
EASYRSA_VARS_FILE=.env
easyrsa build-client-full --subject-alt-name="email:alice@domain.com" guacuser
easyrsa export-p12 guacuser
```

The p12 file is ready to be send to the user, by email for example. He will simply need to import it in his favorite web browser

> The passphrase of the p12 file may be sent by another channel

# documentation

- [Official doc](https://easy-rsa.readthedocs.io/en/latest/#obtaining-and-using-easy-rsa)