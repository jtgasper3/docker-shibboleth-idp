FROM centos:centos7

MAINTAINER John Gasper <jtgasper3@gmail.com>

ENV JRE_HOME /opt/jre1.8.0_60
ENV JAVA_HOME /opt/jre1.8.0_60
ENV JETTY_HOME /opt/jetty
ENV JETTY_BASE /opt/iam-jetty-base
ENV JETTY_MAX_HEAP 512m
ENV PATH $PATH:$JRE_HOME/bin:/opt/container-scripts

RUN yum -y update \
    && yum -y install wget tar unzip which

# Download Java, verify the hash, and install
RUN set -x; \
    java_version=8u60; \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/$java_version-b27/jre-$java_version-linux-x64.tar.gz \
    && echo "49dadecd043152b3b448288a35a4ee6f3845ce6395734bacc1eae340dff3cbf5  jre-$java_version-linux-x64.tar.gz" | sha256sum -c - \
    && tar -zxvf jre-$java_version-linux-x64.tar.gz -C /opt \
    && rm jre-$java_version-linux-x64.tar.gz

# Download Jetty, verify the hash, and install, initialize a new base
RUN set -x; \
    jetty_version=9.3.3.v20150827; \
    wget -O jetty.zip "https://eclipse.org/downloads/download.php?file=/jetty/$jetty_version/dist/jetty-distribution-$jetty_version.zip&r=1" \
    && echo "2972a728bdfba8b1f32d2b4a109abcd7f0c00263  jetty.zip" | sha1sum -c - \
    && unzip jetty.zip -d /opt \
    && mv /opt/jetty-distribution-$jetty_version /opt/jetty \
    && rm jetty.zip \
    && cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty \
    && mkdir -p /opt/iam-jetty-base/modules \
    && mkdir -p /opt/iam-jetty-base/lib/ext \
    && mkdir -p /opt/iam-jetty-base/resources \
    && cd /opt/iam-jetty-base \
    && touch start.ini \
    && $JRE_HOME/bin/java -jar ../jetty/start.jar --add-to-startd=http,https,deploy,ext,annotations,jstl,logging,setuid \
    && sed -i 's/# jetty.http.port=8080/jetty.http.port=80/g' /opt/iam-jetty-base/start.d/http.ini \
    && sed -i 's/# jetty.ssl.port=8443/jetty.ssl.port=443/g' /opt/iam-jetty-base/start.d/ssl.ini \
    && sed -i 's/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"\/>/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"><Set name="showContexts">false<\/Set><\/New>/g' /opt/jetty/etc/jetty.xml

# Download setuid, verify the hash, and place
RUN set -x; \
    wget https://repo1.maven.org/maven2/org/mortbay/jetty/libsetuid/8.1.9.v20130131/libsetuid-8.1.9.v20130131.so \
    && echo "7286c7cb836126a403eb1c2c792bde9ce6018226  libsetuid-8.1.9.v20130131.so" | sha1sum -c - \
    && mv libsetuid-8.1.9.v20130131.so /opt/iam-jetty-base/lib/ext/

# Download Shibboleth IdP, verify the hash, and install
RUN set -x; \
    shibidp_version=3.1.2; \
    wget https://shibboleth.net/downloads/identity-provider/$shibidp_version/shibboleth-identity-provider-$shibidp_version.zip \
    && echo "0c6747b28b1f76eb6fd1a1f2b9fce99c70e70be2e9ef0099f84a006673123027  shibboleth-identity-provider-$shibidp_version.zip" | sha256sum -c - \
    && unzip shibboleth-identity-provider-$shibidp_version.zip -d /opt \
    && cd /opt/shibboleth-identity-provider-$shibidp_version/ \
    && bin/install.sh -Didp.keystore.password=CHANGEME -Didp.sealer.password=CHANGEME -Didp.host.name=localhost.localdomain \
    && cd / \
    && chmod -R +r /opt/shibboleth-idp/ \
    && sed -i 's/ password/CHANGEME/g' /opt/shibboleth-idp/conf/idp.properties \
    && rm -r /shibboleth-identity-provider-$shibidp_version.zip /opt/shibboleth-identity-provider-$shibidp_version/

# Download the library to allow SOAP Endpoints, verify the hash, and place
RUN set -x; \
    wget https://build.shibboleth.net/nexus/content/repositories/releases/net/shibboleth/utilities/jetty9/jetty9-dta-ssl/1.0.0/jetty9-dta-ssl-1.0.0.jar \
    && echo "2f547074b06952b94c35631398f36746820a7697  jetty9-dta-ssl-1.0.0.jar" | sha1sum -c - \
    && mv jetty9-dta-ssl-1.0.0.jar /opt/iam-jetty-base/lib/ext/

ADD iam-jetty-base/ /opt/iam-jetty-base/

# Clean up the install
RUN yum -y remove wget tar unzip; yum clean all

RUN useradd jetty -U -s /bin/false \
    && chown -R jetty:root /opt/jetty \
    && chown -R jetty:root /opt/iam-jetty-base \
    && chown -R jetty:root /opt/shibboleth-idp/logs

ADD container-scripts/ /opt/container-scripts/

RUN chmod -R +x /opt/container-scripts/

## Opening 443 (browser TLS), 8443 (SOAP/mutual TLS auth)... 80 specifically not included.
EXPOSE 443 8443

VOLUME ["/external-mount"]

CMD ["run-shibboleth.sh"]
