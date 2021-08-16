#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 15:15:40
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-16 15:53:23
### 
# 动态替换每次生成的私钥
priv_sk_path=$(ls ../crypto-config/peerOrganizations/org1.blockchainrealestate.com/users/Admin\@org1.blockchainrealestate.com/msp/keystore/)


# priv_sk_path=$(ls ../crypto-config/peerOrganizations/org0.blockchainrealestate.com/users/Admin\@org0.blockchainrealestate.com/msp/keystore/)

cp -rf ./connection-profile/network_temp.json ./connection-profile/network.json

sed -i "s/priv_sk/$priv_sk_path/" ./connection-profile/network.json

docker-compose down -v
docker-compose up -d