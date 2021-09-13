#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 11:57:49
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-09-12 15:18:35
### 



# 根据需求保留，这里相当于使用fabric-samples_v1.4.7中的bin,name其实也就是用的v1.4.7
if [[ `uname` == 'Darwin' ]]; then
    echo "Mac OS"
    export PATH=${PWD}/fabric/mac/bin:${PWD}:$PATH
fi
if [[ `uname` == 'Linux' ]]; then
    echo "Linux"
    # 引入环境变量
    export PATH=${PWD}/fabric/linux/bin:${PWD}:$PATH
fi

CHANNEL_NAME="mychannel"

echo "一、清理环境"
mkdir -p config
mkdir -p crypto-config
rm -rf config/*
rm -rf crypto-config/*
./stop.sh
echo "清理完毕"

echo "二、生成证书和起始区块信息" # --output 生成的证书可以指定路径

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="assetschannel"

echo $CHANNEL_NAME

cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/

# configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block


echo "三、生成系统的区块文件 以及 channel通道的TX文件(创建创世交易)"
# 这里顺序错了
# configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./config/assetschannel.tx -channelID assetschannel

# Generate System Genesis block
configtxgen -profile OneOrgOrdererGenesis -configPath . -channelID $SYS_CHANNEL -outputBlock ./config/genesis.block

# Generate channel configuration block
configtxgen -profile TwoOrgChannel -configPath . -outputCreateChannelTx ./config/assetschannel.tx -channelID $CHANNEL_NAME

echo "区块链 ： 启动"
docker-compose up -d
echo "正在等待节点的启动完成，等待10秒"
sleep 10

# ./ccp-generate.sh 调用其他shell文件的例子
# docker exec cli env 检查环境变量，其他容器类似
# profile 是定义在对应配置文件中的一段 TwoOrgChannel，如果要修改网络结构，那么就从这里修改

