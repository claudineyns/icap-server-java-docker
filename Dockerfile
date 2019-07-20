FROM openjdk:8-jdk-alpine as builder

RUN apk add wget zip

RUN wget --output-document=/tmp/maven.zip http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.zip \
  && unzip /tmp/maven.zip -d /tmp/ \
  && mkdir -p /usr/local/maven/ \
  && mv /tmp/apache-maven-3.6.1/* /usr/local/maven/ \
  && rm -Rf /tmp/apache-maven-3.6.1/

RUN wget --output-document=/tmp/icap-server.zip https://github.com/claudineyns/icap-server/archive/1.0.0-RC02.zip \
  && unzip /tmp/icap-server.zip -d /tmp/ \
  && mv /tmp/icap-server-1.0.0-RC02/ /tmp/source/ \
  && cd /tmp/source && /usr/local/maven/bin/mvn install \
  && mv /tmp/source/target/icap-server-1.0.0-RC02-shaded.jar /tmp/icap-server-java.jar

FROM alpine:3.10.0

RUN mkdir /app

COPY --from=builder /tmp/icap-server-java.jar /app/icap-server-java.jar

RUN apk add --update clamav clamav-daemon openjdk8-jre-base

RUN echo '#!/bin/sh' >> /app/startup.sh \
  && echo 'freshclam' >> /app/startup.sh \
  && echo '/usr/bin/java -jar /app/icap-server-java.jar' >> /app/startup.sh \
  && chmod +x /app/startup.sh

ENTRYPOINT ["/app/startup.sh"]
