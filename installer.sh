#!/bin/bash

zbc_dir=zoobc
zbc_binary=zoobc
zbc_cmd_binary=zcmd
zbc_resource=resource
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
function get_dir_target() {
  echo "$HOME/$zbc_dir.$target"
}
# download_binary downloading binary file from host
function download_binary() {
  echo "DOWNLOADING ZOOBC BINARY ..."
  # shellcheck disable=SC2046
  cd $(get_dir_target) && curl -O http://172.104.47.168/"$target"/$(get_platform)/$zbc_binary
  echo "DOWNLOADING ZOOBC CMD BINARY ..."
  # shellcheck disable=SC2046
  curl -O http://172.104.47.168/"$target"/$(get_platform)/$zbc_cmd_binary
  sleep 5
  chmod 755 "$zbc_binary"
  chmod 755 "$zbc_cmd_binary"
}

################
# MAIN PROCESS #
################
if [[ $target =~ dev|staging|alpha|beta|mainnet ]]; then
  if [ $(ls *.zbc | wc -l) -gt 1 ]; then
    echo "To many *.zbc files found, please leave it one."
    exit
  fi
  echo $(find *.zbc)

  # checking zoobc directory
  [ ! -d "$(get_dir_target)" ] && mkdir "$(get_dir_target)"
  # # checking resource directory
  [ ! -d "$(get_dir_target)/$zbc_resource" ] && mkdir "$(get_dir_target)/$zbc_resource"
  # copying existing certificate file
  wallet_cert=$(find *.zbc)
  [ -f $wallet_cert ] && cp $wallet_cert "$(get_dir_target)/$wallet_cert"
  if
    install_curl
    download_binary
  then
    cd "$(get_dir_target)"
    chmod 755 "$zbc_cmd_binary"
    chmod 755 "$zbc_binary"
    ./$zbc_cmd_binary configure -t="$target"
    echo "Installation finish."
    echo "How to run:"
    echo "sudo $(get_dir_target)/$zbc_binary daemon install --debug"
    echo "sudo $(get_dir_target)/$zbc_binary daemon start --debug"
    echo ""
    echo "note:"
    echo "* --debug enables node's metrics monitoring (by default on port 9090)"
    echo "* if ssh into this server or logged in as root user, there's no need to use sudo (it can be removed from above commands)"
  fi
else
  echo 'usage: sh ./installer.sh dev|staging|alpha|beta|mainnet'
fi
