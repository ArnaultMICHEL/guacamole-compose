#!/bin/bash

######################################################################
##  Bash functions for CLI
######################################################################
## Version   : 1.0
## Author    : Arnault MICHEL (arnault.michel@gmail.com)
## Changelog :
##
## External resources / docs :
##  Keycloak CLI Admin :
##    * http://blog.keycloak.org/2017/01/administer-keycloak-server-from-shell.html
##    * http://blog.keycloak.org/2016/10/registering-new-clients-from-shell.html
##    * https://keycloak.gitbooks.io/documentation/server_admin/topics/admin-cli.html

#Java Settings
JAVA_HOME=${JAVA_HOME:-/usr/bin/java}

testRC() {
  RC=$?
  if [ $RC -ne 0 ] ;
  then
    echo "Erreur lors de l'execution de la dernière commande, sortie :("
    exit 1
  fi
}

use_kcadm() {
    # Install Keycloak CLI standalone client
    [ ! -d $(dirname "$BASH_SOURCE")/tools/keycloak-client-tools  ] && (
    [[ ! -d $(dirname "$BASH_SOURCE")/tools ]] && mkdir $(dirname "$BASH_SOURCE")/tools
    cd $(dirname "$BASH_SOURCE")/tools
    wget https://repo1.maven.org/maven2/org/keycloak/keycloak-client-cli-dist/${KEYCLOAK_VERSION}/keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
    unzip keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
    chmod +x keycloak-client-tools/bin/kcadm.sh
    rm keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
    cd -
    )
    export PATH=${PATH}:$(dirname "$BASH_SOURCE")/tools/keycloak-client-tools/bin/
}

check_terraform_binary() {
  TERRAFORM_VERSION="1.4.5"

  # downloading terraform
  [[ ! -e "$(dirname "$BASH_SOURCE")/tools/terraform" ]] && {
    echo " => installing terraform binary"
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
    unzip /tmp/terraform.zip -d $(dirname "$BASH_SOURCE")/tools
    rm /tmp/terraform.zip
  }
  export PATH=${PATH}:$(dirname "$BASH_SOURCE")/tools
}

confirm2continue() {
  read -p "Press y or Y to continue " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
  fi
}

title() {
  TITLE=$1
  DESC=$2
  echo -ne "\n     "
  for (( i=0 ; i<$((${#TITLE}+8)) ; i++ )); do echo -n "#"; done;
  echo -e "\n     ##  $TITLE  ##"
  echo -n "     "
  for (( i=0 ; i<$((${#TITLE}+8)) ; i++ )); do echo -n "#"; done;

  echo -e "\n\n\n"
  echo ""
  echo " Version     : ${KEYCLOAK_VERSION}"
  echo " Environ.    : ${ENV}"
  echo " URL KC      : https://${KC_HOSTNAME}/"
  echo " Realm       : ${KEYCLOAK_REALM_NAME}"
  echo " CLI account : ${GUACAMOLE_ADMIN_USER}"

  echo -e "\n\n"
  echo "  ${DESC}"
  echo -e "\n\n"
}

authentication4KeycloakAdminCLI() {

  KC_REALM=$1
  KC_ADMIN_CLI_USER=$2
  KC_ADMIN_CLI_PWD=$3

  use_kcadm

  # Configure truststore for TLS server authentication
  kcadm.sh config truststore --trustpass ${KC_TLS_TRUSTSTORE_PWD} ${KC_TLS_TRUSTSTORE}

  # Authentication
  kcadm.sh config credentials \
    --server https://${KC_HOSTNAME} --realm ${KC_REALM} \
    --user ${KC_ADMIN_CLI_USER} --password ${KC_ADMIN_CLI_PWD}
  testRC

  echo ""
  echo "  Login successfull :)"

  echo ""
  confirm2continue

  echo ""
  echo ""
  #echo "  Access Token generated in testRC ~/.keycloak/kcreg.config"
  #cat  ~/.keycloak/kcadm.config
}
