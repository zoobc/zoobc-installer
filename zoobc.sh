#!/bin/bash

dir=zoobc
# platform will check os for installation purposes
function platform(){
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
	echo "DOWNLOADING CURL"
	case $(platform) in
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
	echo "DOWNLOADING BINARY"
	# shellcheck disable=SC2088
	mkdir ~/${dir}
	# shellcheck disable=SC2046
	cd ~/${dir} && curl -O http://172.104.47.168/$(platform)/zoobc
	chmod 755 ~/${dir}/zoobc
}

if install_curl; download_binary; then
  cd ~/${dir} && ./zoobc
#	printf "Finish\nNow run the app"
fi
