#!/usr/bin/env bash
volume=${TECHNOCORE_ROOT}/hals/:/config

# Using socat to forward all traffic directed to the wrapper container on to the actual application.
# https://stackoverflow.com/questions/46099874/how-can-i-forward-a-port-from-one-docker-container-to-another
socat TCP-LISTEN:${SERVICE_PORT},fork TCP:${STACK_NAME}_${service_name}_app:${SERVICE_PORT} &

# Most of this file comes from https://medium.com/@basi/docker-environment-variables-expanded-from-secrets-8fa70617b3bc 
# Thanks Basilio Vera, Rubén Norte, and Jose Manuel Cardona! 

: ${ENV_SECRETS_DIR:=/run/secrets}

env_secret_debug()
{
    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\033[1m$@\033[0m"
    fi
}

# usage: env_secret_expand VAR
#    ie: env_secret_expand 'XYZ_DB_PASSWORD'
# (will check for "$XYZ_DB_PASSWORD" variable value for a placeholder that defines the
#  name of the docker secret to use instead of the original value. For example:
# XYZ_DB_PASSWORD={{DOCKER-SECRET:my-db.secret}}
env_secret_expand() {
    var="$1"
    eval val=\$$var
    if secret_name=$(expr match "$val" "{{DOCKER-SECRET:\([^}]\+\)}}$"); then
        secret="${ENV_SECRETS_DIR}/${secret_name}"
        env_secret_debug "Secret file for $var: $secret"
        if [ -f "$secret" ]; then
            val=$(cat "${secret}")
            export "$var"="$val"
            env_secret_debug "Expanded variable: $var=$val"
        else
            env_secret_debug "Secret file does not exist! $secret"
        fi
    fi
}

env_secrets_expand() {
    for env_var in $(printenv | cut -f1 -d"=")
    do
        env_secret_expand $env_var
    done

    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\n\033[1mExpanded environment variables\033[0m"
        printenv
    fi
}
env_secrets_expand

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
# TODO: This doesn't do a good job of passing env's with spaces in their value.
# "s don't seem to get passed in correctly. Not yet set. is one to break the service.
# https://stackoverflow.com/questions/46141148/declare-env-variable-which-value-include-space-for-docker-docker-compose
env_vars="${env_vars} -e ${env}=${!env}"
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
