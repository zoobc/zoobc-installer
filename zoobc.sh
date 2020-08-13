#!/bin/bash

# ZOOBC INSTALLER SCRIPT
# version: v1
# Description: Installation script for zoobc node. A simple script allowing to download th binary and generating configuration file
# ------------------------------------------------------------------------------------------------------------------------------
zbc_dir=zoobc
zbc_resource=resource
zbc_config=config.toml
zbc_binary=zoobc
zbc_cmd_binary=zcmd
zbc_node_key=node_keys.json

peerPort=8001
apiRPCPort=7000
apiHTTPPort=7001
smithing=true
wellknownPeers=
# shellcheck disable=SC2034
declare -a peersInput
ownerAccountAddress=
nodeSeed=
target=$1
# shellcheck disable=SC2140
alpha=["139.162.109.87:8001","172.104.84.98:8001","139.162.77.52:8001"]
# shellcheck disable=SC2140
dev=["172.104.34.10:8001","45.79.39.58:8001","85.90.246.90:8001"]

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

# checking the depends files like configuration files and more stuff
function checking_depends(){
if [ ! -d ~/${zbc_dir}/{$zbc_resource} ]; then
  mkdir ~/${zbc_dir}/${zbc_resource}
fi
if [ ! -f ~/${zbc_dir}/${zbc_config} ]; then
  case $target in
  'dev'):
    wellknownPeers=$dev;;
  'alpha'):
    wellknownPeers=$alpha;;
  esac

  # shellcheck disable=SC2162
  read -p 'PEER PORT, 8001 as default: ' peerPort
  if [[ -n ${peerPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  [ -z "$peerPort" ] && peerPort=8001

  # shellcheck disable=SC2162
  read -p 'API RPC PORT, 7000 as default: ' apiRPCPort
  if [[ -n ${apiRPCPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  [ -z "$apiRPCPort" ] && apiRPCPort=7000

  # shellcheck disable=SC2162
  read -p 'API HTTP PORT, 7001 as default: ' apiHTTPPort
  if [[ -n ${apiHTTPPort//[0-9]/} ]]; then
    echo "Invalid input, must be a number"
    exit 2
  fi
  [ -z "$apiHTTPPort" ] && apiHTTPPort=7001

  # shellcheck disable=SC2162
  read -p 'OWNER ACCOUNT ADDRESS: ' ownerAccountAddress
  [ -z "$ownerAccountAddress" ] && echo "OWNER ACCOUNT ADDRESS IS EMPTY, NODE WON'T RUNNING. CREATE ONE http://zoobc.one AND SET ownerAccountAddress key on config.toml"
  #read -p 'SMITHING, TRUE|FALSE? '  smithing
  #read -p 'WELLKNOWN PEERS, SEPARATED BY SPACE: ' peersInput
  echo

  # separating peers input
  #wellknownPeers=$(join_by , $peersInput)

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

wellknownPeers=$wellknownPeers
ownerAccountAddress="$ownerAccountAddress"
logLevels=["panic"]
EOF

cp $zbc_config ~/$zbc_dir/$zbc_config
fi

if [ ! -f ~/${zbc_dir}/${zbc_resource}/${zbc_node_key} ]; then 
  # shellcheck disable=SC2162
  read -p 'HAVE NODE`S SEED TO USE ? EMPTY WILL GENERATE ONE FOR YOU? ' nodeSeed
  cd  ~/${zbc_dir} && ./${zbc_cmd_binary} node-admin node-key --node-seed "$nodeSeed"
fi
}

array=(alpha dev)
# shellcheck disable=SC2199
# shellcheck disable=SC2076
if [[ ! " ${array[@]} " =~ " ${target} " ]]; then
  echo "target could be alpha | dev"
  exit
fi
if [ ! -d ~/$zbc_dir ]; then
  mkdir ~/$zbc_dir
fi

 if install_curl; download_binary; checking_depends; then 
#if checking_depends; then 
  echo "FINISH, SMITHING TRUE AS DEFAULT. CHECK INSIDE ~/$zbc_dir/$zbc_config"
fi
