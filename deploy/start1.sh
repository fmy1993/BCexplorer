#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 11:57:49
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-16 22:20:39
### 

# 根据需求保留，这里相当于使用fabric-samples_v1.4.7中的bin
if [[ `uname` == 'Darwin' ]]; then
    echo "Mac OS"
    export PATH=${PWD}/fabric/mac/bin:${PWD}:$PATH
fi
if [[ `uname` == 'Linux' ]]; then
    echo "Linux"
    # 引入环境变量
    export PATH=${PWD}/fabric/linux/bin:${PWD}:$PATH
fi

echo "一、清理环境"
mkdir -p config
mkdir -p crypto-config
rm -rf config/*
rm -rf crypto-config/*
./stop.sh
echo "清理完毕"

echo "二、生成证书和起始区块信息"
cryptogen generate --config=./crypto-config.yaml
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block

echo "区块链 ： 启动"
docker-compose up -d
echo "正在等待节点的启动完成，等待10秒"
sleep 10

echo "三、生成通道的TX文件(创建创世交易)"
configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./config/assetschannel.tx -channelID assetschannel

echo "四、创建通道"
# 通道名是 -c 以参数名给出的，与tx文件本身的路径不同
docker exec cli peer channel create -o orderer.blockchainrealestate.com:7050 -c assetschannel -f /etc/hyperledger/config/assetschannel.tx 

echo "五、节点加入通道"
echo "peer0组织1加入通道"
docker exec cli peer channel join -b assetschannel.block


# 多加入几个节点，直接硬编码
# docker exec cli /bin/bash -c CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp
# docker exec cli /bin/bash -c CORE_PEER_ADDRESS=peer0.org2.blockchainrealestate.com:7051
# docker exec cli /bin/bash -c CORE_PEER_LOCALMSPID="Org2MSP"

# docker exec cli  peer channel join -b assetschannel.block

# echo "peer0组织3加入通道"
# docker exec cli /bin/bash -c CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org0.blockchainrealestate.com/users/Admin@org0.blockchainrealestate.com/msp
# docker exec cli /bin/bash -c CORE_PEER_ADDRESS=peer0.org0.blockchainrealestate.com:7051
# docker exec cli /bin/bash -c CORE_PEER_LOCALMSPID="Org0MSP"

# docker exec cli  peer channel join -b assetschannel.block



