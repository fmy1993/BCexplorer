#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 11:57:49
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-16 21:21:06
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
if [[ "$(docker images -q hyperledger/fabric-ccenv:1.4 2> /dev/null)" == "" ]]; then
  docker pull hyperledger/fabric-ccenv:1.4
fi
if [[ "$(docker images -q hyperledger/fabric-ccenv:latest 2> /dev/null)" == "" ]]; then
  docker tag hyperledger/fabric-ccenv:1.4 hyperledger/fabric-ccenv:latest
fi
docker exec cli peer chaincode instantiate -o orderer.blockchainrealestate.com:7050 -C assetschannel -n blockchain-real-estate -l golang -v 1.0.0 -c '{"Args":["init"]}'

echo "正在等待链码实例化完成，等待5秒"
sleep 5

# 进行链码交互，验证链码是否正确安装及区块链网络能否正常工作
echo "八、验证查询账户信息"
docker exec cli peer chaincode invoke -C assetschannel -n blockchain-real-estate -c '{"Args":["queryAccountList"]}'