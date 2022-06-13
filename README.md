# WIP

# ARMPromExporter
ARM based Prometheus Exporter with GOReverseProxy

[![PatrickDch](https://img.shields.io/badge/PatrickDch-github-green)](https://github.com/PatrickDch)

# Introduction
This repository is an example on how to quickly connect your arm/64 soc`s to prometheus. You can choose to use a nginx reverseproxy or simply the self written goproxy.

No env-foo or complicated stuff needed, only two scripts.

## Security
Because we do not trust anybody ☺️, even in our internal network, we implemented:

- BasicAuth - Prometheus and reverseproxy
- TLS - TLS Security based on best practices (secp384r1)

## General notes
### Nodeexporter version
We are using node_exporter 1.3.1, can be changed in the corresponding scripts.

*arm6_setup.sh is used for eg. rpi2 - rpi3*

*arm64_setup.sh is used for eg. rpi4*

Change the version in the script you need.
```
14: wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-armv6.tar.gz
```
Here just exchange the version number needed, *and be aware that in this example was taken for non 64bit soc`s.*

### .htpasswd
Because we are using basic auth for additional auth you need to generate a username and a password.

## ToDo with nginx reversproxy
If you want to use nginx as a reverseproxy, because it is fast and lightweight for the most arm soc`s.

*Install nginx from the distros package manager, that is up to you which linux you are using (apt, dnf,...)*


## ToDo with goproxy