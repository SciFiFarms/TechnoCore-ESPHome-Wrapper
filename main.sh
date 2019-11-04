#!/usr/bin/env bash
docker run --rm --name ${STACK_NAME}_${service_name}_app \
    -t \
    --network ${STACK_NAME}_${service_name} \
    -v $volume \
    -v ${host_working_dir}/$esphome_core \
    -v ${host_working_dir}/$esphome_app \
    --privileged \
    ${image_provider}/technocore-${service_name}:${TAG}
