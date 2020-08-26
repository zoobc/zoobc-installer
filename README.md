### ZOOBC INSTALLER SCRIPT

ZooBC installation script based on bashscript for help user to install ZooBC node in one easy way.

## How To
1. You can clone this repo or just download the raw format.
   <br>via curl: `curl https://raw.githubusercontent.com/zoobc/zoobc-installer/master/installer.sh -o installer.sh` and also make sure the file permission `chmod +x installer.sh`
2. Copy the certificate file `wallet.zbc` on the same directory with the `installer.sh` file.
   - Upload to server:
       - scp: `scp wallet.zbc {user}@{ip_address}:/{installation_path}`
3. Run installation script:
    <br>`./installer.sh`
4. To run the node:
   - Daemon start:
      - MacOS: `launchctl load /Library/LaunchDaemons/org.zoobc.startup.plist`
      - Linux: `service zoobc start`
   - Daemon stop:
      - MacOS: `launchctl unload /Library/LaunchDaemons/org.zoobc.startup.plist`
      - Linux: `service zoobc stop`
    - Run binary file:
      - `cd $HOME/zoobc{dev|staging|alpha|beta}`
      - `./zoobc`
    - Stop binary file:
      - kill process `CTRL+c`
> The script will create directory `zoobc` on the `$HOME`.

## Compatiibility
- [x] MacOS
- [x] Linux
- [ ] Windows 