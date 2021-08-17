#!/bin/bash

sudo su -c "source vfio-bind.sh $@"

rtnval=$?
if [[ $rtnval -eq 1 ]]; then
    exit 1
fi

result=$(cat driver_data)
sudo rm driver_data

printf "\n"


export containerName=iphoneDockerOSX

var=$(docker ps -aq --filter "name=$containerName")


printf "Getting pci slot\n"

readarray -t array <<<"$result"

IFS="," read -r -a newArray <<<"${array[0]}"

export BIND_PID="${newArray[0]/0000:/}"

sudo modprobe kvm

if [ -z "$var" ]
then
    echo "$containerName contianer not found, creating a new one."
    ./docker_osx_script.sh

else
    echo "Prexisting contianer found."
    echo "Starting container."

    sudo docker start -ai $containerName
fi

while [ "$(docker container inspect -f '{{.State.Running}}' $containerName)" == "true" ]; do
    sleep 5
done

sudo su -c "./unbind.sh $result"
