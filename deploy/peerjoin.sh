#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-16 20:45:33
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-16 21:05:54
### 
echo "peer0组织2加入通道"
# docker exec -it cli bash  
docker exec -it cli /bin/bash export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org2.blockchainrealestate.com/users/Admin@org2.blockchainrealestate.com/msp
docker exec -it cli /bin/bash export CORE_PEER_ADDRESS=peer0.org2.blockchainrealestate.com:7051
docker exec -it cli /bin/bash export CORE_PEER_LOCALMSPID="Org2MSP"

docker exec cli peer channel join -b assetschannel.block

echo "peer0组织0加入通道"
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/org0.blockchainrealestate.com/users/Admin@org0.blockchainrealestate.com/msp
export CORE_PEER_ADDRESS=peer0.org0.blockchainrealestate.com:7051
export CORE_PEER_LOCALMSPID="Org0MSP"

docker exec cli peer channel join -b assetschannel.block