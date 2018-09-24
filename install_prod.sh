# set opal admin and password
export ADMIN=${ADMIN:='administrator'}
export OPAL_ADMIN_PASS=${OPAL_ADMIN_PASS:='password'}


echo "Initialising Opal ..."
./start_prod.sh
echo "waiting 60 second for opal to start ..."
sleep 60
./stop_prod.sh

echo "Configruing opal r server"
sed -i '' 's/#org.obiba.opal.Rserve.host=/org.obiba.opal.Rserve.host=datashield_rserver/g' ds_data/opal/conf/opal-config.properties

./start_prod.sh

echo "sleep for a bit (1 minute) to wait for opal to start up ..."
sleep 60

echo "Begin Configure Test data an Project ..."
# start test docker to input data into opal via python client

cd ../ds_test && docker-compose up -d
cd ../datashield_docker



echo "done sleeping, time to configure opal ..."

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
sleep 10.
# give test user permission to access lifeLines table
docker exec ds_test sh -c "opal perm-table --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS --type USER --project test --subject test  --permission view --add --tables LifeLines"

# give test user permission to use datashield
docker exec ds_test sh -c "opal perm-datashield --opal https://datashield_opal:8443 --user $ADMIN --password $OPAL_ADMIN_PASS --type USER --subject test --permission use --add"

echo "Successfully Configured Test data an Project"

echo "Installing datashield R packages on R server ..."

# install datashield packages
docker exec datashield_rserver R -e "install.packages('datashield', repos=c('https://cran.rstudio.com','https://cran.obiba.org'), dependencies=TRUE)"

##initialise datashield configuraton in opal
python3 insert_base_ds_config.py

echo "Finished installing R packages on R server ..."

echo "Restarting opal to update opal configurations ..."

./stop_prod.sh
./start_prod.sh

echo "finished setting up Opal  - installing R on VM now to allow tests to run"

# finally install R on vm for test purposes
# ./install_r.sh

printf "R intsalled and opal set up - you are ready to go \n"