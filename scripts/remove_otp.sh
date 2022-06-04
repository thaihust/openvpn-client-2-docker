#!/bin/bash

USER=thaiph
cd  /usr/local/openvpn_as/scripts
./confdba -us -p $USER 
./confdba -u -m -k pvt_google_auth_secret_locked -v false -p $USER
./confdba -us -p $USER

./sacli --key "vpn.server.lockout_policy.reset_time" --value "1" ConfigPut
./sacli start
sleep 2
./sacli --key "vpn.server.lockout_policy.reset_time" ConfigDel
./sacli start
