# set opal admin and password
export OPAL_ADMIN_PASS=${OPAL_ADMIN_PASS:='password'}
export R_SERVER_HOST=${R_SERVER_HOST:='datashield_rserver'}

printf "######################\n Stopping Opal to make configuration change...\n######################\n\n"
./stop_prod.sh

printf "Configuring opal r server \n"
sed -i "s/#org.obiba.opal.Rserve.host=/org.obiba.opal.Rserve.host=$R_SERVER_HOST/g" ds_data/opal/conf/opal-config.properties

./start_prod.sh

printf "sleep for a bit (60 seconds) to wait for opal to start up ...\n"
sleep 60

# TODO check if reconfiguring db for opal makes sense here

#printf "done sleeping, time to configure opal ...\n"
# set db 
#echo '{"name": "_identifiers", "defaultStorage":false, "usage": "STORAGE", "usedForIdentifiers":true, "mongoDbSettings" : {"url":"mongodb://datashield_mongo:27017/opal_ids"}}' | docker exec --interactive ds_test sh -c "opal rest --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --content-type 'application/json' -m POST /system/databases" 
# echo '{"name":"test","defaultStorage":false, "usage": "STORAGE", "mongoDbSettings" : {"url":"mongodb://datashield_mongo:27017/opal_data"}}' | docker exec --interactive ds_test sh -c "opal rest --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --content-type 'application/json' -m POST /system/databases"


printf "######################\n updated configuration for opal and poll service \n######################\n\n"