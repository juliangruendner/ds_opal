cd ../ds_test && docker-compose down
cd ../datashield_docker
docker-compose -f docker-compose.prod.yml down
rm -rf ds_data
docker network remove datashield_docker_opal_net