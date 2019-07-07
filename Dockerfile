FROM openjdk:8u212-b04-jdk-slim-stretch as builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget nano zip

RUN wget --output-document=/tmp/maven.zip http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.zip \
  && unzip /tmp/maven.zip -d /var/lib/ \
  && chmod +x /var/lib/apache-maven-3.6.1/bin/mvn \
  && ln -s /var/lib/apache-maven-3.6.1/bin/mvn /usr/bin/mvn

RUN wget --output-document=/tmp/icap-server.zip https://github.com/claudineyns/icap-server/archive/1.0.0-RC02.zip \
  && unzip /tmp/icap-server.zip -d /tmp/ \
  && mv /tmp/icap-server-1.0.0-RC02/ /tmp/source/ \
  && cd /tmp/source && /usr/bin/mvn install \
  && mv /tmp/source/target/icap-server-1.0.0-RC02-shaded.jar /tmp/icap-server-java.jar

FROM alpine:3.10.0

COPY --from=builder /tmp/icap-server-java.jar /tmp/icap-server-java.jar

RUN apk add --update clamav clamav-daemon openjdk8-jre-base

RUN mkdir /app \
 && mv /tmp/icap-server-java.jar /app/

RUN echo '#!/bin/sh' >> /startup.sh \
  && echo 'freshclam' >> /startup.sh \
  && echo 'service clamav-daemon start' >> /startup.sh \
  && echo 'java -jar /app/icap-server-java.jar' >> /startup.sh \
  && chmod +x /startup.sh

ENTRYPOINT ["/startup.sh"]

