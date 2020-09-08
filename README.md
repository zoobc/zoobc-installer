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
   - **Install daemon**:
      - sudo ./zoobc daemon install
   - **Start Daemon**:
      - `sudo ./zoobc daemon start`
   - **Stop Daemon**:
      - `sudo ./zoobc daemon stop`
    - **Status Daemon**:
      - `sudo ./zoobc daemon status`
    - Run binary file:
      - `cd $HOME/zoobc.{dev|staging|alpha|beta}`
      - `./zoobc run`
    - Stop binary file:
      - kill process `CTRL+c`

## Result
The script will create directory `zoobc.{target}` on the `$HOME`. There are several files:
```sh
~/zoobc
├── zoobc #binary
├── cmd #binary
├── config.toml
└── resource
    ├── node_keys.json
```

## Compatibility
- [x] MacOS
- [x] Linux
- [x] Windows 