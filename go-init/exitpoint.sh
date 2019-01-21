#!/usr/bin/env bash

docker rm -f ${stack_name}_${service_name}
kill -s SIGTERM 1
