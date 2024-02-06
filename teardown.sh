#!/bin/bash

cd $(dirname $0)
docker compose down
sudo rm -rf {data,init,tools}

rm -rf config/guacamole/guacamole-groups-and-connections/{.terraform*,terraform.tfstate}
rm -rf config/keycloak/guacamole-realm-config/{.terraform*,terraform.tfstate}
