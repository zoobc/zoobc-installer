#!/bin/bash

zbc_dir=zoobc
zbc_binary=zoobc

# get platform will check os for installation purposes
function get_platform(){
os="$(uname)"
case $os in
'Darwin')
	os='darwin';;
'Linux')
	os='linux';;
'WindowsNT')
	os='windows';;
'MINGW64_NT-10.0')
	os='windows';;
'FreeBSD')
	os='FreeBSD';;
'SunOS')
	os='Solaris';;
'AIX') ;;
*) ;;
esac
echo "$os"
}

# check and install curl
function install_curl(){
if ! curl --version &> /dev/null; then
  echo "DOWNLOADING CURL ..."
  case $(get_platform) in
    'mac')
      brew install curl;;
    'linux')
      apt install curl -y;;
    *);;
  esac
fi
}

# downloading binary file from host
function download_binary(){
if [ ! -f ~/${zbc_dir}/${zbc_binary} ]; then
  echo "DOWNLOADING BINARY ..."
  # shellcheck disable=SC2046
  cd ~/${zbc_dir} && curl -O http://172.104.47.168/$(get_platform)/zoobc
  chmod 755 ~/${zbc_dir}/zoobc
fi
}

if [ ! -d ~/$zbc_dir ]; then
  mkdir ~/$zbc_dir
fi
if install_curl; download_binary; then
  cd ~/${zbc_dir} && ./zoobc
#	printf "Finish\nNow run the app"
fi
