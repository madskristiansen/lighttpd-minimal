FROM ubuntu:xenial as build
# build dependencies
RUN apt-get update && apt-get install -y wget build-essential libbz2-dev libpcre3-dev zlib1g-dev
RUN wget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.53.tar.gz
RUN tar xvfz lighttpd-1.4.53.tar.gz
# build lighttpd
WORKDIR /lighttpd-1.4.53
ADD resources/plugin-static.h src/plugin-static.h
RUN LIGHTTPD_STATIC=yes ./configure -C --enable-static=yes && make -j8 && make install
# not strictly needed, but just in case, lets create a lighttpd user in the build image
RUN useradd lighttpd
# htdocs
ADD resources/index.html /srv/www/htdocs/index.html
# make sure all folders exist and have the correct permissions
RUN mkdir -p /var/log/lighttpd /var/lib/lighttpd /etc/lighttpd /var/tmp
RUN chown -R lighttpd:lighttpd /var/log/lighttpd /srv/www /var/lib/lighttpd /etc/lighttpd
# lighttpd configuration files
ADD resources/lighttpd.conf /etc/lighttpd/lighttpd.conf
ADD resources/conf.d/*.conf /etc/lighttpd/conf.d/
ADD resources/modules.conf /etc/lighttpd/modules.conf
# strip debug symbols off files we are going to include in the final build
RUN strip -s /lib64/ld-linux-x86-64.so.2
RUN strip -s /lib/x86_64-linux-gnu/libcrypt.so.1
RUN strip -s /lib/x86_64-linux-gnu/libc.so.6
RUN strip -s /lib/x86_64-linux-gnu/libbz2.so.1.0
RUn strip -s /lib/x86_64-linux-gnu/libz.so.1
RUN strip -s /lib/x86_64-linux-gnu/libpcre.so.3
RUN strip -s /lib/x86_64-linux-gnu/libcrypt.so.1
RUN strip -s /lib/x86_64-linux-gnu/libpthread.so.0
RUN strip -s /usr/local/sbin/lighttpd
# ok done building the base image


FROM scratch
# system dependencies
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=build /lib/x86_64-linux-gnu/libcrypt.so.1 /lib/x86_64-linux-gnu/libcrypt.so.1
COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=build /lib/x86_64-linux-gnu/libbz2.so.1.0 /lib/x86_64-linux-gnu/libbz2.so.1.0
COPY --from=build /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
COPY --from=build /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/libpcre.so.3
COPY --from=build /lib/x86_64-linux-gnu/libcrypt.so.1 /lib/x86_64-linux-gnu/libcrypt.so.1
COPY --from=build /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0
# lighttpd configuration dependencies
COPY --from=build /etc/lighttpd /etc/lighttpd
COPY --from=build /var/tmp /var/tmp
COPY --from=build /var/run /var/run
COPY --from=build /var/log/lighttpd /var/log/lighttpd
COPY --from=build /srv/www/htdocs /srv/www/htdocs
COPY --from=build /var/lib/lighttpd /var/lib/lighttpd
# lighttpd binary
COPY --from=build /usr/local/sbin/lighttpd /usr/local/sbin/lighttpd

EXPOSE 80

# start lighttpd in non daemon mode
CMD ["/usr/local/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
