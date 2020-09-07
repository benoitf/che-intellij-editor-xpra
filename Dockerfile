FROM alpine:3.12

RUN mkdir /ideaIC-2020.2.1 && wget -qO- https://download.jetbrains.com/idea/ideaIC-2020.2.1.tar.gz | tar -zxv --strip-components=1 -C /ideaIC-2020.2.1 && \
    mkdir /intellij-config /run/xpra /run/user /var/lib/dbus/ && \
    for f in "/intellij-config" "/ideaIC-2020.2.1" "/etc/passwd" "/run/xpra" "/run/user" "/var/lib/dbus"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
RUN apk update && apk add --no-cache git xpra openjdk11-jdk py3-cairo dbus xdg-utils && \
    cp /etc/xpra/xorg.conf /etc/X11/xorg.conf.d/00_xpra.conf && \
    echo "xvfb=Xorg" >> /etc/xpra/xpra.conf && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN apk add --no-cache fontconfig ttf-dejavu && fc-cache -f && \
        ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so && \
        ln -s /lib/libuuid.so.1 /usr/lib/libuuid.so.1 && \
        ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1

ENV LD_LIBRARY_PATH /usr/lib

COPY --chown=0:0 entrypoint.sh /entrypoint.sh

# Set permissions on /etc/passwd and /home to allow arbitrary users to write
COPY entrypoint.sh /
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home && chmod +x /entrypoint.sh

USER 10001
ENV HOME=/home/user
ENV JDK=/usr/lib/jvm/java-11-openjdk JAVA_HOME=/usr/lib/jvm/java-11-openjdk JDK_HOME=/usr/lib/jvm/java-11-openjdk
WORKDIR /projects
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["tail", "-f", "/dev/null"]
