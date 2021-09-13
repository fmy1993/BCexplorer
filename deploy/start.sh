#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 11:57:49
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-09-13 10:55:58
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

# Generate System Genesis block /deploy/fabric/linux/config/configtx.yaml
echo "#######    blcok文件生成  ##########"
configtxgen -profile OneOrgOrdererGenesis -configPath . -channelID $SYS_CHANNEL -outputBlock ./config/genesis.block
echo "#######    tx文件生成  ##########"
# Generate channel configuration block /deploy/fabric/linux/config/configtx.yaml
configtxgen -profile TwoOrgChannel -configPath . -outputCreateChannelTx ./config/assetschannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Org0MSP  ##########"   # 更换-c到-outputAnchorPeersUpdate 
configtxgen -profile TwoOrgChannel -configPath . -outputAnchorPeersUpdate ./config/Org0MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org0MSP

echo "#######    Generating anchor peer update for Org1MSP  ##########"   # 更换-c到-outputAnchorPeersUpdate 
configtxgen -profile TwoOrgChannel -configPath . -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile TwoOrgChannel -configPath . -outputAnchorPeersUpdate ./config/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

echo "区块链 ： 启动"
docker-compose up -d
echo "正在等待节点的启动完成，等待10秒"
sleep 10

# ./ccp-generate.sh 调用其他shell文件的例子
# docker exec cli env 检查环境变量，其他容器类似
# profile 是定义在对应配置文件中的一段 TwoOrgChannel，如果要修改网络结构，那么就从这里修改


echo "四、创建通道"
# 通道名是 -c 以参数名给出的，与tx文件本身的路径不同，并且已经在上一步指定
# -o 配置文件，注意这个是由配置文件中的hostname+domain两个字段组合来的
# docker exec cli peer channel create -o orderer.blockchainrealestate.com:7050 -c assetschannel -f /etc/hyperledger/config/assetschannel.tx 

# echo "========== Creating Channel=========="
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
#     cli peer channel create -o orderer.blockchainrealestate.com:7050 \
#     -c assetschannel -f /etc/hyperledger/config/assetschannel.tx  # 暂时不配tls--tls \
#     #--cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/blockchainrealestate.com/tlsca/tlsca.blockchainrealestate.com-cert.pem

# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
#     -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
#     -e "CORE_PEER_ADDRESS=peer0.org1.blockchainrealestate.com:7051" \
#     cli peer channel join -b assetschannel.block

echo "========== Creating Channel=========="
echo "========== Creating Channel-将order节点加入通道中更恰当=========="
# echo ""
# 将order节点加入通道中更恰当
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
    cli peer channel create -o orderer.blockchainrealestate.com:7050 \
    -c assetschannel -f /etc/hyperledger/config/assetschannel.tx # --tls \
    # --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/blockchainrealestate.com/tlsca/tlsca.blockchainrealestate.com-cert.pem








# docker exec cli peer channel join -b assetschannel.block


docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.org1.blockchainrealestate.com:9051" \
    cli peer channel join -b assetschannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
    peer1.org1.blockchainrealestate.com peer channel fetch newest assetschannel.block \
    -c assetschannel --orderer orderer.blockchainrealestate.com:7050 # --tls \
    # --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/blockchainrealestate.com/tlsca/tlsca.blockchainrealestate.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org1.blockchainrealestate.com/users/Admin@org1.blockchainrealestate.com/msp" \
    peer1.org1.blockchainrealestate.com peer channel join -b assetschannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp" \
    peer0.org2.blockchainrealestate.com peer channel fetch newest assetschannel.block -c assetschannel \
    --orderer orderer.blockchainrealestate.com:7050 # --tls \
    # --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/blockchainrealestate.com/tlsca/tlsca.blockchainrealestate.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp" \
    peer0.org2.blockchainrealestate.com peer channel join -b assetschannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp" \
    peer1.org2.blockchainrealestate.com peer channel fetch newest assetschannel.block -c assetschannel \
    --orderer orderer.blockchainrealestate.com:7050 # --tls \
    # --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/blockchainrealestate.com/tlsca/tlsca.blockchainrealestate.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp" \
    peer1.org2.blockchainrealestate.com peer channel join -b assetschannel.block

echo "========== Channel Creation completed =========="

# echo "五、节点加入通道"
# echo "peer0组织1加入通道"
# docker exec cli peer channel join -b assetschannel.block




# 多加入几个节点，直接硬编码
# docker exec cli /bin/bash -c CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp
# docker exec cli /bin/bash -c CORE_PEER_ADDRESS=peer0.org2.blockchainrealestate.com:9051
# docker exec cli /bin/bash -c CORE_PEER_LOCALMSPID="Org2MSP"

# docker exec cli  peer channel join -b assetschannel.block

# echo "peer0组织3加入通道"
# docker exec cli /bin/bash -c CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org0.blockchainrealestate.com/users/Admin@org0.blockchainrealestate.com/msp
# docker exec cli /bin/bash -c CORE_PEER_ADDRESS=peer0.org0.blockchainrealestate.com:9051
# docker exec cli /bin/bash -c CORE_PEER_LOCALMSPID="Org0MSP"

# docker exec cli  peer channel join -b assetschannel.block


# echo "使用不同org管理员的身份更新anchor节点配置,同样需要切换环境变量"

# -n 是链码的名字，可以自己随便设置
# -v 就是版本号，就是composer的bna版本
# -p 是目录，目录是基于cli这个docker里面的$GOPATH相对的
echo "六、链码安装"
docker exec cli peer chaincode install -n blockchain-real-estate -v 1.0.0 -l golang -p github.com/fmy1993/BCexplorer/chaincode/blockchain-real-estate

#-n 对应前文安装链码的名字 其实就是composer network start bna名字
#-v 为版本号，相当于composer network start bna名字@版本号
#-C 是通道，在fabric的世界，一个通道就是一条不同的链，composer并没有很多提现这点，composer提现channel也就在于多组织时候的数据隔离和沟通使用
#-c 为传参，传入init参数
echo "七、实例化链码"
if [[ "$(docker images -q hyperledger/fabric-ccenv:1.4.4 2> /dev/null)" == "" ]]; then
  docker pull hyperledger/fabric-ccenv:1.4.4
fi
if [[ "$(docker images -q hyperledger/fabric-ccenv:latest 2> /dev/null)" == "" ]]; then
  docker tag hyperledger/fabric-ccenv:1.4.4 hyperledger/fabric-ccenv:latest
fi
docker exec cli peer chaincode instantiate -o orderer.blockchainrealestate.com:7050 -C assetschannel -n blockchain-real-estate -l golang -v 1.0.0 -c '{"Args":["init"]}'

echo "正在等待链码实例化完成，等待5秒"
sleep 5

# 进行链码交互，验证链码是否正确安装及区块链网络能否正常工作
echo "八、验证查询账户信息"
docker exec cli peer chaincode invoke -C assetschannel -n blockchain-real-estate -c '{"Args":["queryAccountList"]}'