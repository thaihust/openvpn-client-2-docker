# Setup OpenVPN client 2 using docker
## Step 1: Clone project

```sh
cd /opt 
git clone https://github.com/thaihust/openvpn-2-client.git
cd openvpn-2-client
mkdir -p /etc/vpn-client
cp vpn_config.yaml /etc/vpn-client
```

## Step 2: Access OpenVPN AS portal and download client.ovpn
- Download client.ovpn from OpenVPN AS. Ex: https://vpn.fago-labs.com
- Copy the new file `client.ovpn` into directory: `etc/vpn-client`

## Step 3: Change dotenv
- Open file `dotenv` and change the below parameters:
  - VPN_USER: vpn username
  - VPN_PASSWORD: vpn password
  - VPN_TOTP_CODE: TOTP code (equivalent OTP QR code)
  - VPN_URL: change to url of openvpn server. Ex: https://vpn.fago-labs.com

## Step 4: Run config

```sh
docker run --rm --name vpn-client \
--network host \
--env-file ./dotenv \
--env VPN_RUN_OPTION=configure \
-v /etc/vpn-client:/etc/vpn-client \
thaihust/fgl-vpn-client:18.04 
```

## Step 5: Run openvpn-client

```sh
docker run -tid --privileged --restart always \
--name vpn-client \
--network host \
--cap-add CAP_NET_ADMIN \
--env-file ./dotenv \
--env VPN_RUN_OPTION=run \
-v /etc/vpn-client:/etc/vpn-client \
thaihust/fgl-vpn-client:18.04
```
