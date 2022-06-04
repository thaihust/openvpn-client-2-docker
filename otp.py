#! /usr/bin/env python
import sys
import pyotp
import base64
import pexpect
import click
import yaml

help = "v -> VPN V\n o -> VPN O\n p -> VPN P"

#config_path = sys.argv[3]
#ovpn_path = sys.argv[4]
#with open(config_path) as config_file:
#    vpn_config = yaml.safe_load(config_file)
#vpn_user=vpn_config['vpn_user']
#vpn_password=vpn_config['vpn_password']
#vpn_totp_code=vpn_config['vpn_totp_code']
#vpn_url=vpn_config['vpn_url']

@click.command()
@click.option('--vpn', default='v', type=click.Choice(['v','o','p']), help=help)
@click.option('--vpn_config_path', default='vpn_config.yaml', type=click.STRING, help=help)
@click.option('--ovpn_path', default='client.ovpn', type=click.STRING, help=help)
@click.option('--debug', is_flag=True, help='Enable debugging - prints output to stdout')
def main(vpn, vpn_config_path, ovpn_path, debug):
    with open(vpn_config_path) as vpn_config_path:
        vpn_config = yaml.safe_load(vpn_config_path)
    vpn_user=vpn_config['vpn_user']
    vpn_password=vpn_config['vpn_password']
    vpn_totp_code=vpn_config['vpn_totp_code']
    vpn_url=vpn_config['vpn_url']

    username = vpn_user
    pwd = base64.b64decode(vpn_password)

    while True:

        totp = pyotp.totp.TOTP(vpn_totp_code)
        otp = totp.now()
        password = '{}'.format(pwd)
        #password = '{}{}'.format(pwd, totp.now())

        if vpn == 'v':
            command = 'openvpn --config ' + ovpn_path 

        elif vpn == 'o':
            command = 'openvpn --config ' + ovpn_path 

        elif vpn == 'p':
            command = 'openconnect --juniper ' + vpn_url

        else:
            sys.exit()

        if vpn == 'p':

            process = pexpect.spawn(command)

            if debug:
                process.logfile = sys.stdout

            try:
                process.expect('username:')
                process.sendline(username)
                process.expect('password:')
                process.sendline(password)
                print 'Connected'

                while True:
                    process.expect('.+', timeout=None)
                    output = process.match.group(0)
                    if output != '\r\n':
                        print 'openconnect: ', output
                        break

            except pexpect.EOF:
                print 'Invalid username and/or password'

            except pexpect.TIMEOUT:
                print 'Connection failed!'

        else:

            process = pexpect.spawn(command)

            if debug:
                process.logfile = sys.stdout

            try:
                process.expect('Enter Auth Username:')
                process.sendline(username)
                process.expect('Enter Auth Password:')
                process.sendline(password)
                process.expect('CHALLENGE: Enter Google Authenticator Code')
                process.sendline(otp)
                print 'Attempting connection'
                process.expect('Initialization Sequence Completed')
                print 'Connected'
                # Attempt reconnection
                while True:
                    process.expect('.+', timeout=None)
                    output = process.match.group(0)
                    if output != '\r\n':
                        print 'openvpn: ', output
                        break

            except pexpect.EOF:
                print 'Invalid username and/or password'

            except pexpect.TIMEOUT:
                print 'Cannot connect to OpenVPN server!'


if __name__ == '__main__':
    main()
