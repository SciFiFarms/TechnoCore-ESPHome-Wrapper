#!/usr/bin/env bash
volume=${TECHNOCORE_ROOT}/hals/:/config

# Using socat to forward all traffic directed to the wrapper container on to the actual application.
# https://stackoverflow.com/questions/46099874/how-can-i-forward-a-port-from-one-docker-container-to-another
socat TCP-LISTEN:${SERVICE_PORT},fork TCP:${STACK_NAME}_${service_name}_app:${SERVICE_PORT} &

# This allows us to pass the envs set in the compose.yml file into the wrapped service.
# https://askubuntu.com/questions/275965/how-to-list-all-variables-names-and-their-current-values
env_vars=
for env in $(declare -xpn | cut -d " " -f 3- | cut -d "=" -f 1 | \
        grep -v HOME | \
        grep -v HOSTNAME | \
        grep -v OLDPWD | \
        grep -v PATH | \
        grep -v PWD | \
        grep -v SHLVL | \
        grep -v TERM 
    ); do
    env_vars="${env_vars} -e ${env}=\"${!env}\""
done
docker run --rm --name ${STACK_NAME}_${service_name}_app \
    -t \
    --network ${STACK_NAME}_${service_name} \
    $env_vars \
    -v $volume \
    -v ${host_working_dir}/$esphome_core \
    -v ${host_working_dir}/$esphome_app \
    -l traefik.frontend.rule=$ESPHOME_ROUTING_LABEL \
    -l traefik.frontend.priority=$ESPHOME_ROUTING_LABEL_PRIORITY \
    -l traefik.port=${SERVICE_PORT} \
    -l traefik.enable=true \
    -l traefik.tags=ingress  \
    -l traefik.docker.network=${STACK_NAME:-technocore}_${service_name} \
    -l traefik.redirectorservice.frontend.entryPoints=http \
    -l traefik.redirectorservice.frontend.redirect.entryPoint=https \
    -l traefik.webservice.frontend.entryPoints=https \
    -l com.ouroboros.enable=true \
    --privileged \
    ${image_provider}/technocore-${service_name}:${TAG}
