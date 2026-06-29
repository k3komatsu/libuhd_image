# UHD Docker image

## Pulling the Docker image

- UHD 4.7 (Base image: 24.04)

```sh
$ docker pull ghcr.io/k3komatsu/uhd:v4.7
```

- UHD 4.8 (Base image: 24.04)

```sh
$ docker pull ghcr.io/k3komatsu/uhd:v4.8
```

- UHD 4.9 (Base image: 24.04)

```sh
$ docker pull ghcr.io/k3komatsu/uhd:v4.9
```

- UHD 4.10 (Base image: 26.04)

```sh
$ docker pull ghcr.io/k3komatsu/uhd:v4.10
```

## Start a shell inside the container

Run the container with host networking and an interactive bash shell, then run `uhd_find_devices`, `uhd_usrp_probe`, `uhd_image_loader`, etc. The `uhd_image_downloader` should already have been run in the image, so you normally do not need to run it again.

```sh
$ docker run -it --net=host --rm ghcr.io/k3komatsu/uhd:v4.7 /bin/bash
```

## Flash FPGA images to a USRP

This section explains how to flash an FPGA image to an X300/X310 USRP so that both SFP+ ports operate at 10GbE.

Inside the container, FPGA images are located in `/usr/local/share/uhd/images`. To flash an image, run:

```sh
# enter the container
$ docker run -it --net=host --rm ghcr.io/k3komatsu/uhd:v4.7 /bin/bash
# flash the FPGA image (replace <IP ADDR>, {device}, and {image} as needed)
$ uhd_image_loader --args="type=x300,addr=<IP ADDR>" --fpga-path=/usr/local/share/uhd/images/usrp_{device}_fpga_{image}.bit
```

`{device}` should be either `x300` or `x310`. `{image}` is either `HG` or `XG`.

- Images ending with `XG` enable both SFP+ ports at 10GbE.
- Images ending with `HG` leave port 0 at 1GbE and the other port at 10GbE.

After flashing successfully, `uhd_find_devices` should show output similar to:

```sh
$ uhd_find_devices
[INFO] [UHD] linux; GNU C++ version 13.2.0; Boost_108300; UHD_4.6.0.0+ds1-5.1ubuntu0.24.04.1
--------------------------------------------------
-- UHD Device 0
--------------------------------------------------
Device Address:
    serial: 3229FE2
    addr: 192.168.30.2
    addr: 192.168.40.2
    fpga: XG
    name:
    product: X310
    type: x300
```

Make sure the host PC's 10GbE interface IP addresses are configured accordingly.

## Set the USRP IP address

To change a USRP IP address, for example from `192.168.10.2` to `192.168.10.35`, run:

```sh
$ /usr/local/lib/uhd/utils/usrp_burn_mb_eeprom --args="addr=192.168.10.2" --values="ip-addr0=192.168.10.35"
```

Note:
- Use `ip-addr2` to set the IP for SFP+ port 0 when using an XG image.
- Use `ip-addr3` to set the IP for SFP+ port 1 for XG/HG images.

Reference: https://files.ettus.com/manual/page_usrp_x3x0.html



## Change the base image or base OS

You can change the base image by editing the `FROM` line in the Dockerfile (for example, `FROM ubuntu:24.04`).
After modifying the Dockerfile, build the image with:

```sh
docker build . -t {new-image-name}:{tag}
```
