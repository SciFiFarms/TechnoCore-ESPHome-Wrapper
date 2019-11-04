#!/usr/bin/env bash

docker rm -f ${STACK_NAME}_${service_name}_app
kill -s SIGTERM 1
