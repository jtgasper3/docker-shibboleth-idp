## Overview
This Docker image contains a deployed Shibboleth IdP 3.1.1 running on Java Runtime 1.7 update 79 and Jetty 9.2.10 running on the latest CentOS 7 base.

This image can be used as a base image overriding the configuration with local changes, or as an appliance and used directly by using a local configuration.

Jetty has been configured to use setuid and http traffic is handled by a non-root user. Ports 443 and 8443 are opened for traffic.

> This image requires acceptance of the Java License Agreement (<http://www.oracle.com/technetwork/java/javase/terms/license/index.html>).

## Image Goal
The goal behind this Dockerfile image is to provide a demonstrably secure end to end deployment of every external asset (Java, Jetty, Shibboleth IdP, and extensions). Each downloaded asset is verified against cryptographic hashes obtained from each vendor, but and in the Dockerfile to make the build essentially deterministic. **Because of the deterministic nature of the build, users should feel confident in using this Dockerfile/image either directly or as a base for applying their configuration on top of.**

## Running
Two methods of using the image described here.

### Appliance Use
This will use the default container storage to store the idp configuration. 

#### Starting the container

```
$ docker run -dP --name="idp-test" -v ~/docker/shib-config:/external-mount jtgasper3/docker-shibboleth-idp 
```

> If you do not have an existing configuration to import, after starting the container you **must** run:   
> `$ docker exec -it idp-test reset-idp.sh`   
> **Otherwise you will be running with a well-known (unsafe) encryption/signing key.** (Be sure to restart the container to accept the new config.)


#### Importing an existing configuration
Update the Jetty/Shibboleth config by importing an existing configuration into a running container: 

```
$ docker exec idp-test import.sh

```
Stop the container and restart it to pick up changes.

#### Exporting the current configuration
Besure to export any changes and store them elsewhere. If a container is deleted before you export your config, signing/config keys will be losts.

```
$ docker exec idp-test export.sh

```

#### Misc Notes on Execution
The Shibboleth IdP logs can be explicitly mapped to local storage by adding `-v /local/path:/opt/shibboleth-idp/logs` when starting the container.

Other advance docker storage strategies are also possible.


### Using as a Base
This image is ideal for use as a base image for ones own deployment. 

Assuming that you have a similar layout with your configuration, credentials, and war customizations. The struction could look like:

```
basedir
|-- .dockerignore
|-- Dockerfile
|-- conf
|   |-- attribute-filter.xml
|   |-- attribute-resolver.xml
|   |-- credentials.xml
|   |-- idp.properties
|   |-- ldap.properties
|   |-- login.config
|   |-- metadata-providers.xml
|   |-- relying-party.xml
|   |-- services.xml
|-- credentials
|   |-- idp-backchannel.crt
|   |-- idp-backchannel.jks
|   |-- idp-backchannel.p12
|   |-- idp-encryption.crt
|   |-- idp-encryption.key
|   |-- idp-signing.crt
|   |-- idp-signing.key
|   |-- sealer.jks
|   |-- sealer.kver
|-- keystore
|-- metadata
|   |-- idp-metadata.xml
|-- webapps
    |-- images
    |   |-- dummylogo-mobile.png
    |   |-- dummylogo.png
    |-- WEB-INF
        |-- web.xml

```

Next, assuming the Dockerfile is similar to this example:

```
FROM jtgasper3/shibboleth-idp

ADD conf/ /opt/shibboleth-idp/conf/
ADD credentials/ /opt/shibboleth-idp/credentials/
ADD metadata/ /opt/shibboleth/metadata/
ADD webapp/ /opt/shibboleth-idp/webapp/

ADD keystore $JETTY_BASE/etc/keystore
```

>This will take the base image that is available in the Docker repository and download it. Next, it overrides all of the base files with your local configuration.

The dependant image can be built by running:

```
docker build --tag="<org_id>/shibboleth-idp" .
```

Now, just execute the new image:

```
$ docker run -dP --name="shib-local-test" org_id/docker-shibboleth-idp 
```
> The `-v` parameter is not needed as in the other case because there is no need to import/export the configuration.

## Building

From source:

```
$ docker build --tag="org_id/shibboleth-idp" github.com/jtgasper3/docker-shibboleth-idp
```

## Author

  * John Gasper (<https://jtgasper.github.io>, <jgasper@unicon.net>, <jtgasper3@gmail.com>)

## References
The following references provided some form of guidence for this project:

* https://github.com/Maluuba/docker-files/tree/master/docker-jetty
* https://registry.hub.docker.com/u/dockerfile/java/
* https://github.com/jfroche/docker-shibboleth-idp
* http://mrbluecoat.blogspot.com/2014/10/docker-traps-and-how-to-avoid-them.html

## LICENSE

Copyright 2015 John Gasper

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
