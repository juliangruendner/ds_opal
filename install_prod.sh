# set opal admin and password
export OPAL_ADMIN_PASS=${OPAL_ADMIN_PASS:='password'}
export R_SERVER_HOST=${R_SERVER_HOST:='datashield_rserver'}

printf "######################\nInitialising Opal ...\n######################\n\n"
./start_prod.sh
echo "waiting 60 second for opal to start ..."
sleep 60
./stop_prod.sh

printf "Configuring opal r server \n"
sed -i "s/#org.obiba.opal.Rserve.host=/org.obiba.opal.Rserve.host=$R_SERVER_HOST/g" ds_data/opal/conf/opal-config.properties

./start_prod.sh

printf "sleep for a bit (60 seconds) to wait for opal to start up ...\n"
sleep 60

printf "Begin Configure Test data an Project ...\n"
# start test docker to input data into opal via python client

cd ../ds_test && docker-compose up -d
cd ../datashield_docker

ADMIN='administrator'

printf "done sleeping, time to configure opal ...\n"

# set db
echo '{"name": "_identifiers", "defaultStorage":false, "usage": "STORAGE", "usedForIdentifiers":true, "mongoDbSettings" : {"url":"mongodb://datashield_mongo:27017/opal_ids"}}' | docker exec --interactive ds_test sh -c "opal rest --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --content-type 'application/json' -m POST /system/databases" 
echo '{"name":"test","defaultStorage":false, "usage": "STORAGE", "mongoDbSettings" : {"url":"mongodb://datashield_mongo:27017/opal_data"}}' | docker exec --interactive ds_test sh -c "opal rest --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --content-type 'application/json' -m POST /system/databases"

# create a test project
echo '{"name":"test","title":"test", "database": "test"}' | docker exec --interactive ds_test sh -c "opal rest --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --content-type 'application/json' -m POST /projects"


# upload the needed lifeLines files
docker exec ds_test sh -c "opal file --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS -up /testdata/LifeLines.sav /projects"

# import the needed csv files to the test project
docker exec ds_test sh -c "opal import-spss --opal https://datashield_opal:8443 -u $ADMIN -p $OPAL_ADMIN_PASS --destination test --path /projects/LifeLines.sav"

# create a test user
docker exec ds_test sh -c "opal user --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS --add --name test --upassword test123"
sleep 10
# give test user permission to access lifeLines table
docker exec ds_test sh -c "opal perm-table --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS --type USER --project test --subject test  --permission view --add --tables LifeLines"

# give test user permission to use datashield
docker exec ds_test sh -c "opal perm-datashield --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS --type USER --subject test --permission use --add"

#
docker exec ds_test sh -c "opal rest --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS -m POST '/datashield/packages?name=datashield'"


cd ../ds_test && docker-compose stop
cd ../datashield_docker

printf "Successfully Configured Test data an Project \n"

printf "Installing datashield R packages on R server ...\n"

# install datashield packages
docker exec datashield_rserver R -e "install.packages('datashield', repos=c('https://cran.rstudio.com','https://cran.obiba.org'), dependencies=TRUE)"

printf "Finished installing R packages on R server ...\n"

printf "Restarting opal to update opal configurations ...\n"

./stop_prod.sh
./start_prod.sh

printf "finished setting up Opal  - installing R on VM now to allow tests to run \n"

# finally install R on vm for test purposes
# ./install_r.sh

printf "######################\n R intsalled and opal set up - you are ready to go \n######################\n\n"