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
      brew install curl
      ;;
    'linux')
      apt install curl -y
      ;;
    esac
  fi
}

# get_dir_target to get joined target directory
function get_dir_target(){
  echo "$HOME/$zbc_dir.$target"
}
# download_binary downloading binary file from host
function download_binary() {
  echo "DOWNLOADING ZOOBC BINARY ..."
  # shellcheck disable=SC2046
  cd $(get_dir_target) && curl -O http://172.104.47.168/"$target"/$(get_platform)/$zbc_binary
  chmod 755 "$(get_dir_target)/$zbc_binary"
  echo "DOWNLOADING ZOOBC CMD BINARY ..."
  # shellcheck disable=SC2046
  cd $(get_dir_target) && curl -O http://172.104.47.168/"$target"/$(get_platform)/$zbc_cmd_binary
  chmod 755 "$(get_dir_target)/$zbc_cmd_binary"
}

# generate_service will generate service script to systemd called zoobc.service
function generate_service() {
  echo 'Generating daemon service ...'
  case $(get_platform) in
  'linux')
    if [ ! -f "/lib/systemd/system/zoobc.service" ]; then
      cat >zoobc.service <<EOF
[Unit]
Description=zoobc node service
[Service]
Type=simple
User=root
Group=root
#emergency (0), alert (1), critical (2), error (3), warning (4), notice (5), info (6), and debug (6)
LogLevelMax=3
WorkingDirectory=$HOME/$(get_dir_target)
ExecStart=$HOME/zoobc/zoobc --debug --cpu-profile
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
      sudo cp zoobc.service /lib/systemd/system/zoobc.service
      systemctl daemon-reload
    fi
    ;;
  'darwin')
    if [ ! -f /Library/LaunchDaemons/org.zoobc.startup.plist ]; then
      cat >org.zoobc.startup.plist <<EOF
<?xml version"1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.zoobc.startup</string>
  <key>ServiceDescription</key>
  <string>ZOOBC NODE Service zoobc.com</string>
  <key>WorkingDirectory</key>
  <string>$HOME/$(get_dir_target)</string>
  <key>ProgramArguments</key>
  <array>
    <string>./zoobc</string>
  </array>
  <key>UserName</key>
  <string>root</string>
  <key>GroupName</key>
  <string>root</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF
      sudo cp org.zoobc.startup.plist /Library/LaunchDaemons
    fi
    ;;
  *)
    echo "For $(get_platform) please check on zoobc.com for more detail"
    ;;
  esac
}

function start_service() {
  echo "Starting Service ..."
  case $(get_platform) in
  'darwin')
    launchctl load /Library/LaunchDaemons/org.zoobc.startup.plist
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
  [ ! -d "$(get_dir_target)" ] && mkdir "$(get_dir_target)"
  # checking resource directory
  [ ! -d "$(get_dir_target)/$zbc_resource" ] && mkdir "$(get_dir_target)/$zbc_resource"
  # copying existing certificate file
  [ -f $wallet_cert ] && cp $wallet_cert "$(get_dir_target)/$wallet_cert"
  if
    install_curl
    download_binary
  then
    cd "$(get_dir_target)" && ./$zbc_cmd_binary configure -t="$target"
    generate_service
    echo "Installation finish."
    case $(get_platform) in
    'linux')
      echo "To running daemon: service zoobc start"
      ;;
    'darwin')
      echo "To running daemon: launchctl load /Library/LaunchDaemons/org.zoobc.startup.plist"
      ;;
    *) ;;
    esac
    echo "Or running manually: cd $(get_dir_target) && ./$zbc_binary"
  fi
else
  echo 'usage: sh ./installer.sh dev|staging|alpha|beta'
fi
