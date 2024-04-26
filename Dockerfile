FROM ubuntu:20.04

ARG AUTH_TOKEN
ARG PASSWORD=rootuser

RUN apt-get update \
    && apt-get install -y locales nano ssh sudo python3 curl wget unzip \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

# Install QEMU/KVM dependencies
RUN apt-get update && apt-get install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virtinst \
    && rm -rf /var/lib/apt/lists/*

# Configure QEMU/KVM
RUN echo "qemu_system_x86_64=/usr/bin/qemu-system-x86_64" >> /etc/libvirt/qemu.conf \
    && echo "user = \"root\"" >> /etc/libvirt/qemu.conf \
    && echo "group = \"kvm\"" >> /etc/libvirt/qemu.conf \
    && echo "cgroup_device_acl = [" >> /etc/libvirt/qemu.conf \
    && echo "   \"/dev/null\", \"/dev/full\", \"/dev/zero\"," >> /etc/libvirt/qemu.conf \
    && echo "   \"/dev/random\", \"/dev/urandom\"," >> /etc/libvirt/qemu.conf \
    && echo "   \"/dev/ptmx\", \"/dev/kvm\", \"/dev/kqemu\"," >> /etc/libvirt/qemu.conf \
    && echo "   \"/dev/rtc\",\"/dev/hpet\"]" >> /etc/libvirt/qemu.conf

# Start libvirtd service
RUN /etc/init.d/libvirtd start

ENV UBUNTU_FRONTEND=noninteractive \
    LANG=en_US.utf8

RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && rm /ngrok.zip \
    && mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${AUTH_TOKEN} 22 &" >> /s.sh \
    && echo "sleep 5" >> /s.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"SSH Info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:${PASSWORD}\\\")\" || echo \"\nError：AUTH_TOKEN，Reset ngrok token & try\n\"" >> /s.sh \
    && echo '/usr/sbin/sshd -D' >> /s.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo root:${PASSWORD}|chpasswd \
    && chmod 755 s.sh

# Add QEMU/KVM commands to the entrypoint script
RUN echo "# QEMU/KVM commands" >> /s.sh \
    && echo "virsh list --all" >> /s.sh \
    && echo "virsh console powshield" >> /s.sh

EXPOSE 1337 2222 5900 5901
CMD ["/bin/bash", "/s.sh"]
