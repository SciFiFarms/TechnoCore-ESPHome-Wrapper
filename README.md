# TechnoCore image
This repo is used as a part of the [TechoCore stack](https://github.com/SciFiFarms/TechnoCore). For more information, checkout TechnoCore's [overview](https://github.com/SciFiFarms/TechnoCore/blob/master/CONTRIBUTING.md#overview).

This image is to workaround the fact that Swarm doesn't currently support mounting USB devices. 
https://github.com/docker/swarmkit/issues/2682

It uses go-init to allow for the removal of the pio image before the platformio 
image starts. 

This isn't an ideal solution as it still has issues filling the logs with errors, 
but it does mean that as long as a USB device is plugged in, it should be flashable. 
