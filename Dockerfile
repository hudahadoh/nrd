FROM debian
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget nano curl python3 python3-pip tmate \
    xfce4 xvfb xserver-xorg-video-dummy policykit-1 xbase-clients \
    python3-packaging python3-psutil python3-pip python3-xdg python3-venv python3-tk python3-dev \
    libcairo2 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 \
    libnspr4 libnss3 libpango-1.0-0 libutempter0 \
    libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 libxtst6 firefox-esr sudo dbus-x11

# Install Chrome Remote Desktop
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
RUN dpkg -i chrome-remote-desktop_current_amd64.deb
RUN apt-get install --assume-yes --fix-broken

# Add user 'xb', set password, add to sudo group and chrome-remote-desktop group
RUN adduser --disabled-password --gecos "" xb \
    && echo "xb:password" | chpasswd \
    && usermod -aG sudo xb \
    && usermod -aG chrome-remote-desktop xb

# Set up SSH and tmate with root permissions
RUN mkdir /run/sshd \
    && echo "sleep 5" >> /openssh.sh \
    && echo "tmate -F &" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:147 | chpasswd \
    && chmod 755 /openssh.sh

# Expose necessary ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Start SSH and XFCE
CMD /openssh.sh && startxfce4 :1030
