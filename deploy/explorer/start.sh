#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 15:15:40
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-16 19:51:14
### 
# 动态替换每次生成的私钥
priv_sk_path_org1=$(ls ../crypto-config/peerOrganizations/org1.blockchainrealestate.com/users/Admin\@org1.blockchainrealestate.com/msp/keystore/)

priv_sk_path_org2=$(ls ../crypto-config/peerOrganizations/org2.blockchainrealestate.com/users/Admin\@org2.blockchainrealestate.com/msp/keystore/)

priv_sk_path_org0=$(ls ../crypto-config/peerOrganizations/org0.blockchainrealestate.com/users/Admin\@org0.blockchainrealestate.com/msp/keystore/)

cp -rf ./connection-profile/network_temp.json ./connection-profile/network.json

sed -i "s/priv_sk_org1/$priv_sk_path_org1/" ./connection-profile/network.json

sed -i "s/priv_sk_org2/$priv_sk_path_org2/" ./connection-profile/network.json

sed -i "s/priv_sk_org0/$priv_sk_path_org0/" ./connection-profile/network.json

docker-compose down -v
docker-compose up -d