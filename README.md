# ARMPromExporter
ARM based Prometheus node exporter with GOReverseProxy

[![PatrickDch](https://img.shields.io/badge/PatrickDch-github-green)](https://github.com/PatrickDch)

# Introduction
This repository is an example on how to quickly connect your arm/64 soc`s to prometheus. You can choose to use a nginx reverseproxy or simply the self written goproxy.

No env-foo or complicated stuff needed, only two scripts.

## Security
Because we do not trust anybody ☺️, even in our internal network, we implemented:

- BasicAuth - Prometheus and reverseproxy
- TLS - TLS Security based on best practices (secp384r1)

## General notes
You need to have golang and requirements installed on your system. Because it is a "stupid" script it will not check for that.
This script will not update the node_exporter, infact you could rerun it with the appropriate version number.

```
dnf install golang wget tar sudo
```
```
apt install golang wget tar sudo
```
### Nodeexporter version
We are using node_exporter 1.3.1, can be changed in the corresponding scripts.

*arm non 64bit is used for eg. rpi2 - rpi3*

*arm 64bit is used for eg. rpi4*

### .htpasswd
*If you are using nginx.*

Because we are using basic auth for additional auth you need to generate a username and a password.

You will need to change -->
nginx/.htpasswd -> /data/.htpasswd
```
%USER%:%PW%
```
I suggest to use apachetools or an online generator like https://wtools.io/generate-htpasswd-online

## httpsexporter.go
If you choose to go with the GoProxy you need to addapt the basic auth. 
The gobinary will not read any .htpasswd files out of security concerns.
 
First you need to generate your basic auth just like before in *.htpasswd*.

Than add that to the open go code

*httpsexporter.go*
```
21:	if user == "%USER%" {
22:		// password is "hello"
23:		return "%BASEAUTH%"
	}
```


## ToDo with nginx reversproxy
If you want to use nginx as a reverseproxy, because it is fast and lightweight for the most arm soc`s.

*Install nginx from the distros package manager, that is up to you which linux you are using (apt, dnf,...)*

Be aware that the setup script is creating */data/cert* with autogenerated certificates and */data/.htpasswd* .

Basicaly you could leave the nginx default config as is after you fill in the */data/.htpasswd* and run 
```
bash ./arm_setup.sh
```

It will expose 4443 which you will later need to fill into your promtheus config.


## ToDo with goproxy
If you are using the goproxy you do not need to do anything further except for running the 
```
bash ./arm_setup.sh
```
and take the (g) GoProxy way.

Thats it - nothing else to do.

# Prometheus config example
```
    static_configs:
    - targets: ['192.168.122.198']
    metrics_path: '/metrics'
    basic_auth:
      username: 'metric'
      password: 'password'
    scheme: https
    tls_config:
        insecure_skip_verify: true