# set opal admin and password
export ADMIN=${ADMIN:='administrator'}
export OPAL_ADMIN_PASS=${OPAL_ADMIN_PASS:='password'}
export R_SERVER_HOST=${R_SERVER_HOST:='datashield_rserver'}

printf "######################\n Stooping Opal to initiate update sequence ...\n######################\n\n"

./stop_prod.sh

printf "Configuring opal r server \n"
sed -i "s/#org.obiba.opal.Rserve.host=/org.obiba.opal.Rserve.host=$R_SERVER_HOST/g" ds_data/opal/conf/opal-config.properties

./start_prod.sh

printf "sleep for a bit (60 seconds) to wait for opal to start up ...\n"
sleep 60



printf "######################\n opal has now been updated - you are ready to go \n######################\n\n"