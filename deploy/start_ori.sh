#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-09-12 15:15:32
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-09-12 15:29:42
### 
#!/bin/bash

# 本脚本从头构建一个区块链网络
# 请确保cryptogen 和 configtxgen 这两个可执行文件已经被正确安装
# 创建一个通道 assetschannel

# 一、环境清理
echo "一、环境清理"
mkdir -p config # -p是保证可以一次性创建  a/b 这样形式的目录，如果不存在就创建，存在也不报错
mkdir -p crypto-config
rm -fr config/* # 清理文件夹下的其他材料,主要是通道的材料
rm -fr crypto-config/* # docker 宿主文件删除了挂载的文件会删除吗？ 要持久化的话主机路径应该不能删除，删除了volume也会失效的
echo "清理完毕"

# 二、生成证书和起始区块信息
echo "二、生成证书和起始区块信息"
cryptogen generate --config=./crypto-config.yaml #默认都是在配置文件当前路径生成文件夹
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block

# 三、启动区块链网络
echo "区块链 ： 启动"
docker-compose up -d        # 按照docker-compose.yaml的配置启动区块链网络并在后台运行
echo "正在等待节点的启动完成，等待10秒"
sleep 10                    # 启动整个区块链网络需要一点时间，所以此处等待10s，让区块链网络完全启动

# 四、生成通道(这个动作会创建一个创世交易，也是该通道的创世交易)
# channel === 通道
echo "三、生成通道的TX文件(这个动作会创建一个创世交易，也是该通道的创世交易)"
configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./config/assetschannel.tx -channelID assetschannel

# 五、在区块链上按照刚刚生成的TX文件去创建通道
# 该操作和上面操作不一样的是，这个操作会写入区块链，必须进入cli容器才能运行这个命令，cli命令才有这个功能
echo "五、在区块链上按照刚刚生成的TX文件去创建通道" #/etc/hyperledger/config 这个路径分别映射了order节点容器以及cli容器的路径
docker exec cli peer channel create -o orderer.blockchainrealestate.com:7050 -c assetschannel -f /etc/hyperledger/config/assetschannel.tx

# 六、让节点去加入到通道    分布式网络里一定是有多个节点的
echo "六、让节点去加入到通道"
docker exec cli peer channel join -b assetschannel.block

# 七、链码安装
# -n 是链码的名字，可以自己随便设置
# -v 就是版本号，就是composer的bna版本
# -p 是目录，目录是基于cli这个docker里面的$GOPATH相对的
# 此处安装的是示例链码，后续课程会自己编写
echo "七、链码安装"
docker exec cli peer chaincode install -n blockchain-real-estate -v 1.0.0 -l golang -p github.com/fmy1993/BCexplorer/chaincode/blockchain-real-estate
#docker exec cli peer chaincode install -n blockchain-real-estate -v 1.0.0 -l golang -p github.com/togettoyou/blockchain-real-estate/chaincode/blockchain-real-estate
#八、实例化链码
#-n 对应前文安装链码的名字 其实就是composer network start bna名字
#-v 为版本号，相当于composer network start bna名字@版本号
#-C 是通道，在fabric的世界，一个通道就是一条不同的链，composer并没有很多提现这点，composer提现channel也就在于多组织时候的数据隔离和沟通使用
# 所谓多条链也就是多条通道
#-c 为传参，传入init参数
# 如果需要升级链码，只需要 替换后命令后面的版本号即可，eg:  
# docker exec cli peer chaincode install -n blockchain-real-estate -v 1.0.1 -l golang -p github.com/fmy1993/blockchain-real-estate/chaincode/blockchain-real-estate
echo "八、实例化链码"
docker exec cli peer chaincode instantiate -o orderer.blockchainrealestate.com:7050 -C assetschannel -n blockchain-real-estate -l golang -v 1.0.0 -c '{"Args":["init"]}'
# 使用upgrade命令按照版本号，
# docker exec cli peer chaincode upgrade -o orderer.blockchainrealestate.com:7050 -C assetschannel -n blockchain-real-estate -l golang -v 1.0.1 -c '{"Args":["init"]}'


# 进行链码交互，验证链码是否正确安装及区块链网络能否正常工作
# docker exec cli peer chaincode invoke -C assetschannel -n blockchain-real-estate -c '{"Args":[""]}'
# docker exec cli peer chaincode invoke -C assetschannel -n blockchain-real-estate -c '{"Args":["queryAccountList"]}'