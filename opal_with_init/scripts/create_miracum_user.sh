#!/bin/bash

USER=$1
CERT=$2

echo "create user $USER with cert $CERT "
opal user --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --add --name $USER --ucertificate $CERT

echo "Created User: $USER with cert $CERT" >> miracum_projects.config

echo "give user $USER permission to use datashield"
opal perm-datashield --opal https://localhost:8443 --user  administrator --password  $OPAL_ADMINISTRATOR_PASSWORD --type USER --subject $USER --permission use --add

