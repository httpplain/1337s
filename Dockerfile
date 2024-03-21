FROM ubuntu:latest

ARG AUTH_TOKEN
ARG PASSWORD=rootuser

RUN apt-get update && apt-get install -y locales nano ssh sudo python3 curl wget unzip \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && rm ngrok.zip \
    && mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${AUTH_TOKEN} 22 &" >> /s.sh \
    && echo "sleep 5" >> /s.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print('SSH Info:\\nssh root@' + \
    json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '))\"" >> /s.sh \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo root:${PASSWORD} | chpasswd \
    && chmod 755 /s.sh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
