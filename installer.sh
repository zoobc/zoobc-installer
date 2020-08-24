#!/bin/bash

zbc_dir=zoobc
zbc_binary=zoobc
zbc_cmd_binary=zcmd
zbc_resource=resource
wallet_cert=wallet.zbc
target=$1

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

# checking curl
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

# downloading binary file from host
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

if [[ $target =~ dev|staging|alpha|beta ]]; then
  # checking zoobc directory
  [ -f "./${wallet_cert}" ] && cp wallet.zbc ~/${zbc_dir}/${wallet_cert}
  [ ! -d ~/$zbc_dir ] && mkdir ~/$zbc_dir
  [ ! -d ~/$zbc_dir/$zbc_resource ] && mkdir ~/$zbc_dir/$zbc_resource 
  if
    install_curl
    download_binary
  then
    cd ~/${zbc_dir} && ./${zbc_cmd_binary} configure -t="$target"
  fi
else
  echo 'usage: sh ./installer.sh dev|staging|alpha'
fi
