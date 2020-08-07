#!/bin/bash

# ZOOBC INSTALLER SCRIPT
# version: v1
# Description: Installation script for zoobc node. A simple script allowing to download th binary and generating configuration file
# ------------------------------------------------------------------------------------------------------------------------------
zbc_dir=zoobc
zbc_config=config.toml
zbc_binary=zoobc

peerPort=8001
apiRPCPort=7000
apiHTTPPort=7001
smithing=true
wellknownPeers=
declare -a peersInput
ownerAccountAddress=

# join array by limiter
function join_by { local IFS="$1"; shift; echo "$*"; }

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
  cd ~/${zbc_dir} && curl -O http://172.104.47.168/$(get_platform)/$zbc_binary
  chmod 755 ~/${zbc_dir}/zbc_binary
fi
}

# checking the depends files like configuration files and more stuff
function checking_depends(){
if [ ! -f ~/${zbc_dir}/${zbc_config} ]; then
  read -p 'PEER PORT: ' peerPort
  if [[ -n ${peerPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  read -p 'API RPC PORT: ' apiRPCPort
  if [[ -n ${peerPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  read -p 'API HTTP PORT: ' apiHTTPPort
  if [[ -n ${peerPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  read -p 'OWNER ACCOUNT ADDRESS": ' ownerAccountAddress

  read -p 'SMITHING, TRUE|FALSE? '  smithing
  read -p 'WELLKNOWN PEERS, SEPARATED BY SPACE: ' peersInput
  echo

  # separating peers input
  wellknownPeers=$(join_by , $peersInput)
  
  # shellcheck disable=SC1044
  cat > ${zbc_config} <<EOF
resourcePath="./resource"
dbName="zoobc.db"
badgerDBName="zoobc.kv/"
nodeKeyFile="node_keys.json"
snapshotPath="./resource/snapshots"

peerPort=$peerPort
apiRPCPort=$apiRPCPort
apiHTTPPort=$apiHTTPPort
monitoringPort=9090
cpuProfilingPort=6060

maxAPIRequestPerSecond=10
apiReqTimeoutSec=2
smithing=$smithing
proofOfOwnershipReqTimeoutSec=2

wellknownPeers=[$wellknownPeers]
ownerAccountAddress="$ownerAccountAddress"
logLevels=["panic"]
EOF

cp $zbc_config ~/$zbc_dir/$zbc_config
fi
}


if [ ! -d ~/$zbc_dir ]; then
  mkdir ~/$zbc_dir
fi
if install_curl; download_binary; then
  cd ~/${zbc_dir} && ./$zbc_binary
#	printf "Finish\nNow run the app"
fi
