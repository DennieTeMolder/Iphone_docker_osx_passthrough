Cookiefile=$(pwd -P)/mycookie
touch $Cookiefile
Cookie="$(xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/')"
echo $Cookie | xauth -f $Cookiefile nmerge -

sudo docker run -it \
        --privileged \
        --device /dev/kvm \
        --ulimit memlock=-1:-1 \
        --name "$containerName" \
        -p 50922:10022 \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e "DISPLAY=${DISPLAY:-:0.0}" \
        -v $Cookiefile:/cookie \
        -e XAUTHORITY=/cookie \
        -v "${PWD}/output.env:/env" \
        -e EXTRA="-device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1
        -device vfio-pci,host=$BIND_PID,bus=port.1" \
        sickcodes/docker-osx:big-sur
