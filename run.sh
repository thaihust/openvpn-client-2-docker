#!/bin/bash

if [ "${VPN_RUN_OPTION}" == "configure" ]; then
  ENCODED_PASSWD=$(/usr/bin/python ${VPN_CLIENT_BIN_DIR}/gen-base64-otp-code.py ${VPN_PASSWORD})
  sed -i "s|VPN_PASSWORD|${ENCODED_PASSWD}|g" ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml
  sed -i "s|VPN_USER|${VPN_USER}|g" ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml
  sed -i "s|VPN_TOTP_CODE|${VPN_TOTP_CODE}|g" ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml
  sed -i "s|VPN_URL|${VPN_URL}|g" ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml
elif [ "${VPN_RUN_OPTION}" == "run" ]; then
  /usr/bin/python ${VPN_CLIENT_BIN_DIR}/otp.py --vpn v --vpn_config_path ${VPN_CLIENT_CONFIG_DIR}/vpn_config.yaml --ovpn_path ${VPN_CLIENT_CONFIG_DIR}/client.ovpn
else
  echo "Invalid value for VPN_RUN_OTION"
fi
