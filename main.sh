#!/usr/bin/env bash
if [ -d /config/ ]
then
    volume=${host_working_dir}/hals/:/config
else
    volume=${stack_name}_${service_name}:/config 
fi
echo "Volume: $volume"

docker run --rm --name ${stack_name}_${service_name}_app \
    -t --network ${stack_name}_web \
    -e CA="$(cat /run/secrets/ca)" \
    -e MQTT_BROKER="$(cat /run/secrets/domain)" \
    -e MQTT_USERNAME="$(cat /run/secrets/mqtt_username)" \
    -e MQTT_PASSWORD="$(cat /run/secrets/mqtt_password)" \
    -e VAULT_TOKEN="$(cat /run/secrets/token)" \
    -p 6051:5678 \
    -v $volume \
    -v ${host_working_dir}/$esphome_core \
    --privileged \
    ${image_provider}/technocore-${service_name}:${TAG}
