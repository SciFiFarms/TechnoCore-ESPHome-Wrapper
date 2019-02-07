#!/usr/bin/env bash
if [ -d /config/ ]
then
    volume=${host_working_dir}/esphomeyaml/config/:/config
else
    volume=${stack_name}_${service_name}:/config 
fi
echo "Volume: $volume"

docker run --rm --name ${stack_name}_${service_name} \
    -t --network ${stack_name}_web \
    -e CA="$(cat /run/secrets/ca)" \
    -e MQTT_USERNAME="$(cat /run/secrets/mqtt_username)" \
    -e MQTT_PASSWORD="$(cat /run/secrets/mqtt_password)" \
    -e VAULT_TOKEN="$(cat /run/secrets/token)" \
    -v $volume \
    --privileged \
    ${image_provider}/technocore-${service_name}:${TAG}
