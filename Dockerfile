FROM ubuntu:22.04

ARG AUTH_TOKEN
ARG PASSWORD=rootuser

RUN apt-get update \
    && apt-get install -y locales nano rdp-server xrdp xorgxrdp \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV UBUNTU_FRONTEND=noninteractive \
    LANG=en_US.utf8

RUN wget -O xrdp.zip https://github.com/neutrinolabs/xrdp/releases/download/v0.9.16/xrdp-v0.9.16-src.zip \
    && unzip xrdp.zip \
    && cd xrdp-v0.9.16 \
    && ./bootstrap \
    && ./configure \
    && make \
    && make install \
    && rm -rf xrdp.zip xrdp-v0.9.16 \
    && mkdir /run/sshd \
    && echo "/xrdp --nodaemon &" >> /s.sh \
    && echo "sleep 5" >> /s.sh \
    && echo "echo \"RDP Info:\nRDP Address: \$(curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '))\")\nRDP Password: ${PASSWORD}\"" >> /s.sh \
    && echo '/usr/sbin/sshd -D' >> /s.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo root:${PASSWORD}|chpasswd \
    && chmod 755 s.sh

EXPOSE 3389 2222 1111
CMD ["/bin/bash", "/s.sh"]
