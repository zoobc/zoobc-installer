#!/bin/bash

zbc_dir=zoobc
zbc_binary=zoobc
zbc_cmd_binary=zcmd
zbc_resource=resource
wallet_cert=wallet.zbc
target=$1

# get_platform just inform what kind os version
function get_platform() {
  os="$(uname)"
  case $os in
  'Darwin')
    os='darwin'
    ;;
  'Linux')
    os='linux'
    ;;
  'WindowsNT')
    os='windows'
    ;;
  'MINGW64_NT-10.0')
    os='windows'
    ;;
  'FreeBSD')
    os='freebsd'
    ;;
  'SunOS')
    os='solaris'
    ;;
  *) ;;
  esac
  echo "$os"
}

# install_curl checking curl
function install_curl() {
  if ! curl --version &>/dev/null; then
    echo 'DOWNLOADING CURL ...'
    case $(get_platform) in
    'mac')
      brew insatll curl
      ;;
    'linux')
      apt install curl -y
      ;;
    esac
  fi
}

# download_binary downloading binary file from host
function download_binary() {
  if [ ! -f ~/${zbc_dir}/${zbc_binary} ]; then
    echo "DOWNLOADING ZOOBC BINARY ..."
    # shellcheck disable=SC2046
    cd ~/${zbc_dir} && curl -O http://172.104.47.168/$(get_platform)/$zbc_binary
    chmod 755 ~/${zbc_dir}/${zbc_binary}
  fi
  if [ ! -f ~/${zbc_dir}/${zbc_cmd_binary} ]; then
    echo "DOWNLOADING ZOOBC CMD BINARY ..."
    # shellcheck disable=SC2046
    cd ~/${zbc_dir} && curl -O http://172.104.47.168/$(get_platform)/$zbc_cmd_binary
    chmod 755 ~/${zbc_dir}/${zbc_cmd_binary}
  fi
}

# generate_service will generate service script to systemd called zoobc.service
function generate_service() {
  case $(get_platform) in
  'linux')
    cat >zoobc.service <<EOF
[Unit]
Description=zoobc node service
[Service]
Type=simple
User=root
Group=root
#emergency (0), alert (1), critical (2), error (3), warning (4), notice (5), info (6), and debug (6)
LogLevelMax=3
WorkingDirectory=~/zoobc
ExecStart=~/zoobc/zoobc --debug --cpu-profile
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    sudo cp zoobc.service /etc/system/systemd/zoobc.service
    systemctl daemon-reload
    ;;
  'darwin')
    cat >zoobc.node.list <<EOF
<?xml version"1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>zoobc.node</string>
  <key>Program</key>
  <string>~/zoobc/zoobc</string>
  <key>ServiceDescription</key>
  <string>ZOOBC NODE Service zoobc.com</string>
  <key>UserName</key>
  <string>root</string>
  <key>GroupName</key>
  <string>root</string>
</dict>
</plist>
EOF
    sudo cp zoobc.node.list /Library/LaunchDaemons
    sudo lauchctl load /Library/LaunchDaemons/zoobc.node.plist
    ;;
  *)
    echo "For $(get_platform) please check on zoobc.com for more detail"
    ;;
  esac
}

function start_service() {
  case $(get_platform) in
  'darwin')
    sudo lauchctl start zoobc.node
    ;;
  'linux')
    service zoobc start
    ;;
  *)
    echo "For $(get_platform) please check on zoobc.com for more detail"
    ;;
  esac
}

################
# MAIN PROCESS #
################
if [[ $target =~ dev|staging|alpha|beta ]]; then
  # checking zoobc directory
  [ ! -d ~/$zbc_dir ] && mkdir ~/$zbc_dir
  # checking resource directory
  [ ! -d ~/$zbc_dir/$zbc_resource ] && mkdir ~/$zbc_dir/$zbc_resource
  # copying existsing certificate file
  [ -f $wallet_cert ] && cp $wallet_cert ~/${zbc_dir}/${wallet_cert}
  if
    install_curl
    download_binary
  then
    cd ~/${zbc_dir} && ./${zbc_cmd_binary} configure -t="$target"
    generate_service
    start_service
  fi
else
  echo 'usage: sh ./installer.sh dev|staging|alpha'
fi
