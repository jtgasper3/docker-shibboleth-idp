## Overview
This Docker image contains a deployed Shibboleth IdP 2.4.3 running on Java Runtime 1.7 update 71 running on the latest CentOS 7.

The intention is that this image can be used as a base overriding the configuration with local changes, or as an appliance and used directly.

> This image requires acceptance of the Java License Agreement (<http://www.oracle.com/technetwork/java/javase/terms/license/index.html>).

## Running

```
$ docker run docker run -itdP jtgasper3/docker-shibboleth-idp
```

## Building

From source:

```
$ docker build --tag="jtgasper3/docker-shibboleth-idp" github.com/jtgasper3/docker-shibboleth-idp
```

## Author

  * John Gasper (<https://jtgasper.github.io>, <jgasper@unicon.net>, <jtgasper3@gmail.com>)

## References
The following references provided some form of guidence for this project:

* https://github.com/Maluuba/docker-files/tree/master/docker-jetty
* https://registry.hub.docker.com/u/dockerfile/java/
* https://github.com/jfroche/docker-shibboleth-idp

## LICENSE

Copyright 2014 John Gasper

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
