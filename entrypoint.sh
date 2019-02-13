#!/usr/bin/env bash

function restart_for_usb() {
    until docker run --rm --device /dev/ttyUSB0 ${image_provider}/technocore-${service_name}:${TAG} --help &> /dev/null
    do
        touch /var/needs_reboot
        echo "USB Device not plugged in."
        sleep 10
    done

    if [ -f /var/needs_reboot ]; then
        echo "Loading USB device. Will reboot."
        kill -s SIGTERM 1
    else 
        echo "Loaded USB device."
    fi
}

restart_for_usb &

docker rm -f ${stack_name}_${service_name}_app &> /dev/null
# Need to reboot nginx so that any cached/stale IP addresses for the service are flushed. 
docker service update --force --detach ${stack_name}_nginx 
exit 0
