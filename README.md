# A minimal lighttpd Docker image

The time has come to start exploring alternatives to nginx for those servers only serving static files (e.g. SPA frontends) or acting as reverse proxies to a backend.

[lighttpd](http://www.lighttpd.net/) is an open-source web server optimized for speed-critical environments while remaining standards-compliant, secure and flexible. It was originally written by Jan Kneschke as a proof-of-concept of the c10k problem – how to handle 10,000 connections in parallel on one server, but has gained worldwide popularity. Its name is a portmanteau of "light" and "httpd".

To pull the latest image:

```
docker pull arca.dk/mads/lighttpd:latest
```

This experimental Docker image is **3.43 MB** in size. It includes the bare minimum for the statically linked server to run and includes the following modules:

```
mod_auth
mod_accesslog
mod_access
mod_redirect
mod_rewrite
mod_cgi
mod_fastcgi
mod_scgi
mod_ssi
mod_proxy
mod_indexfile
mod_dirlisting
mod_staticfile
```

To add new modules, you need to add them to the `resources/plugin-static.h` and rebuild the image.

The default configuration will dump access- and server-logs to `/dev/stderr`, so logs are easy to collect in case this is being executed inside a cluster with centralized logging (e.g. with [fluentd](https://www.fluentd.org/)). To change any configuration option, modify the `lighttpd.conf` or the relevant configureation in `conf.d` and rebuild the image.

## Build

Clone the source:

```
git clone git@gitlab.com:madskristiansen/lighttpd.git
```

Build the image:

```
docker build -t lighttpd:test .
```

## Test

Start the Docker image and publish port 80:

```
docker run -p 80:80 --rm --name lighttpd lighttpd:test
```

From another terminal, check that the server responds correctly:

```
curl -I localhost

HTTP/1.1 200 OK
Content-Type: text/html
Accept-Ranges: bytes
ETag: "420230896"
Last-Modified: Mon, 18 Mar 2019 18:08:05 GMT
Content-Length: 95
Date: Mon, 18 Mar 2019 18:50:37 GMT
Server: lighttpd/1.4.53
```

As you can see, the server is running `lighttpd/1.4.53`. In the default configuration, you should see the access- and server-logs dumped to the console.