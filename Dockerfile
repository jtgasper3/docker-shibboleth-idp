FROM centos:centos7

MAINTAINER John Gasper <jtgasper3@gmail.com>

ENV JRE_HOME /opt/jre1.7.0_71
ENV JAVA_HOME /opt/jre1.7.0_71
ENV JETTY_HOME /opt/jetty
ENV JETTY_BASE /opt/iam-jetty-base
ENV PATH $PATH:$JRE_HOME/bin:/opt/container-scripts

RUN yum -y update \
    && yum -y install wget tar unzip

# Downlaod Java, verify the hash, and install
RUN set -x; \
    java_version=7u71; \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/$java_version-b14/jre-$java_version-linux-x64.tar.gz \
    && echo "7605134662f6c87131eca5745895fe84  jre-$java_version-linux-x64.tar.gz" | md5sum -c - \
    && tar -zxvf jre-$java_version-linux-x64.tar.gz -C /opt \
    && rm jre-$java_version-linux-x64.tar.gz


# Download Jetty, verify the hash, and install, initialize a new base
RUN set -x; \
    jetty_version=9.2.7.v20150116; \
    wget -O jetty.zip "https://eclipse.org/downloads/download.php?file=/jetty/$jetty_version/dist/jetty-distribution-$jetty_version.zip&r=1" \
    && echo "0d7dc3e4c72d63bd34fabef8c96dabf7b744a15d  jetty.zip" | sha1sum -c - \
    && unzip jetty.zip -d /opt \
    && mv /opt/jetty-distribution-$jetty_version /opt/jetty \
    && rm jetty.zip \
    && cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty \
    && mkdir -p /opt/iam-jetty-base/modules \
    && mkdir -p /opt/iam-jetty-base/lib/ext \
    && cd /opt/iam-jetty-base \
    && touch start.ini \
    && $JRE_HOME/bin/java -jar ../jetty/start.jar --add-to-startd=http,https,deploy,ext,annotations,jstl,logging,setuid \
    && sed -i 's/jetty.port=8080/jetty.port=80/g' /opt/iam-jetty-base/start.d/http.ini \
    && sed -i 's/https.port=8443/https.port=443/g' /opt/iam-jetty-base/start.d/https.ini \
    && sed -i 's/jetty.secure.port=8443/jetty.secure.port=443/g' /opt/iam-jetty-base/start.d/ssl.ini \
    && sed -i 's/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"\/>/<New id="DefaultHandler" class="org.eclipse.jetty.server.handler.DefaultHandler"><Set name="showContexts">false<\/Set><\/New>/g' /opt/jetty/etc/jetty.xml

# Download setuid, verify the hash, and place
RUN set -x; \
    wget https://repo1.maven.org/maven2/org/mortbay/jetty/libsetuid/8.1.9.v20130131/libsetuid-8.1.9.v20130131.so \
    && echo "7286c7cb836126a403eb1c2c792bde9ce6018226  libsetuid-8.1.9.v20130131.so" | sha1sum -c - \
    && mv libsetuid-8.1.9.v20130131.so /opt/iam-jetty-base/lib/ext/


# Download Shibboleth IdP, verify the hash, and install
RUN set -x; \
    shibidp_version=2.4.3; \
    wget https://shibboleth.net/downloads/identity-provider/2.4.3/shibboleth-identityprovider-$shibidp_version-bin.zip \
    && echo "9f2787c64f56c6f6020ac5d01e62bf0f8851755c  shibboleth-identityprovider-$shibidp_version-bin.zip" | sha1sum -c - \
    && unzip shibboleth-identityprovider-$shibidp_version-bin.zip -d /opt \
    && rm shibboleth-identityprovider-2.4.3-bin.zip \
    && cd /opt/shibboleth-identityprovider-$shibidp_version \
    && sed -i 's/keystorePassword="\${idp.keystore.pass}"/keystorePassword="CHANGEME"/g' /opt/shibboleth-identityprovider-$shibidp_version/src/installer/resources/build.xml \
    && ./install.sh


# Download the library to allow SOAP Endpoints, verify the hash, and place
RUN set -x; \
    wget https://build.shibboleth.net/nexus/content/repositories/releases/net/shibboleth/utilities/jetty9/jetty9-dta-ssl/1.0.0/jetty9-dta-ssl-1.0.0.jar \
    && echo "2f547074b06952b94c35631398f36746820a7697  jetty9-dta-ssl-1.0.0.jar" | sha1sum -c - \
    && mv jetty9-dta-ssl-1.0.0.jar /opt/iam-jetty-base/lib/ext/

ADD iam-jetty-base/ /opt/iam-jetty-base/

# Clean up the install
RUN yum -y remove wget tar unzip; yum clean all

RUN useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /opt/jetty \
    && chown -R jetty:jetty /opt/iam-jetty-base


ADD container-scripts/ /opt/container-scripts/
RUN chmod -R +x /opt/container-scripts/

## Opening 443 (browser TLS), 8443 (SOAP/mutual TLS auth)... 80 specifically excluded.
EXPOSE 443 8443

VOLUME ["/external-mount"]

CMD ["run-shibboleth.sh"]
