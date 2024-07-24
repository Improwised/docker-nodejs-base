FROM improwised/docker-nodejs-base:20.13.1-b85a5c4-1715759223


COPY  rootfs/etc/s6-overlay/s6-rc.d/apply-env /etc/s6-overlay/s6-rc.d/apply-env

RUN chmod 755 /etc/s6-overlay/s6-rc.d/apply-env/run

RUN chmod 755 /etc/s6-overlay/s6-rc.d/apply-env/up

RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/apply-env
