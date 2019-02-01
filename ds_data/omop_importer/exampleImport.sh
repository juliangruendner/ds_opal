#! /bin/bash

#echo "create a test project..." 
# in this case creating the project is not neccessary as the standard installation already creates the project on the first run
# echo '{"name":"test","title":"test", "database": "test"}' | opal rest --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD --content-type 'application/json' -m POST /projects

echo "upload the files..."
#opal file --opal https://localhost:8443 -u administrator -p $OPAL_ADMINISTRATOR_PASSWORD -up /omop_importer/CNSIM/CNSIM.zip /projects

echo "import the CNSIM and DASIM test files to the test project..."
#opal import-xml --opal https://localhost:8443 --user administrator --password $OPAL_ADMINISTRATOR_PASSWORD --path /projects/CNSIM.zip --destination test

# begin simple csv import
# see documentation here http://opaldoc.obiba.org/en/latest/python-user-guide/import/import-csv.html

opal file --opal https://localhost:8443 -u administrator -p password -up /omop_importer/csv/test.csv /projects

opal import-csv --opal https://localhost:8443  --user administrator --password password --destination test --path /projects/test.csv --tables testcsv --separator ';' --type Area