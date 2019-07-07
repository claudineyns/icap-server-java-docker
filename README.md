# icap-server-java-docker

Simple ICAP server implementation written in Java for docker.

### Examples

These use cases assume you are using "c-icap-client" from the following project:

* [The c-icap project](http://c-icap.sourceforge.net/)

List available services:

```
c-icap-client -i <server> -s info -req /
```

Submit a file to look for malwares:

```
c-icap-client -i <server> -s virus_scan -req /send -f <full-path-to-file>
```

### Installing

From the command-line, type the following lines:

```
docker image pull claudiney/icap-server-java
docker run --rm -p 1344:1344 -d claudiney/icap-server-java
```
