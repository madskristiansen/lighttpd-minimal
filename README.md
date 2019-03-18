# A minimal lighttpd Docker image

lighttpd is an open-source web server optimized for speed-critical environments while remaining standards-compliant, secure and flexible. It was originally written by Jan Kneschke as a proof-of-concept of the c10k problem – how to handle 10,000 connections in parallel on one server, but has gained worldwide popularity. Its name is a portmanteau of "light" and "httpd".

This Docker image is 5.47 MB in size. It includes the bare minimum for the statically linked server to run and includes the following modules:

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
docker run --detach -p 80:80 --name lighttpd lighttpd:test
```

Check that the server responds correctly:

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

As you can see, the server is running `lighttpd/1.4.53`.