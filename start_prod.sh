source ../opal_poll.config

printf "######################\nInitialising Opal and installing Datashield and RServer ...\n######################\n\n"

docker-compose -f docker-compose.prod.yml up -d
