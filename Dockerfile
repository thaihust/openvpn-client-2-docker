FROM ubuntu:18.04

ENV VERSION=release/2.5
ENV OS_RELEASE=bionic 
ENV VPN_CLIENT_BIN_DIR=/usr/local/bin/vpn-client
ENV VPN_CLIENT_CONFIG_DIR=/etc/vpn-client

COPY requirements.txt /opt/requirements.txt

RUN apt-get update && apt-get install -y wget add-apt-key \
    && wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add - \
    && echo "deb http://build.openvpn.net/debian/openvpn/$VERSION $OS_RELEASE main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
    && apt-get update && apt-get install openvpn python-pip -y \
    && pip install -r /opt/requirements.txt && rm -f /opt/requirements.txt \
    && pip install pyyaml \
    && mkdir -p ${VPN_CLIENT_BIN_DIR} ${VPN_CLIENT_CONFIG_DIR}

COPY otp.py ${VPN_CLIENT_BIN_DIR}/otp.py
COPY run.sh ${VPN_CLIENT_BIN_DIR}/run.sh
COPY gen-base64-otp-code.py ${VPN_CLIENT_BIN_DIR}/gen-base64-otp-code.py
COPY client.ovpn ${VPN_CLIENT_CONFIG_DIR}/client.ovpn
COPY vpn_config.yaml ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml

VOLUME /etc/vpn-client

CMD ["/usr/local/bin/vpn-client/run.sh"]
