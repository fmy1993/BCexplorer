#!/bin/bash
###
 # @Descripttion: 
 # @version: 
 # @Author: fmy1993
 # @Date: 2021-08-15 15:15:40
 # @LastEditors: fmy1993
 # @LastEditTime: 2021-08-15 17:17:04
### 

echo "运行单元测试，检查区块链网络是否连接成功，需要有go环境，若无可忽略"
go test sdk_test.go
echo "开始准备启动应用"
sleep 2

echo "一、清理环境、删除旧容器"
# 容器中的app路径docker 
rm -rf app
# 删除之前构建的镜像
docker rm -f blockchain-real-estate-application

# 在编译过程中会下载go的依赖
echo "二、开始打包编译"
if [[ `uname` == 'Darwin' ]]; then
  # docker build -f  Dockerfile.Mac -t fmy1993/BCexplorer-application:v1 .
  docker build -f  Dockerfile.Mac -t togettoyou/blockchain-real-estate-application:v1 .
fi

if [[ `uname` == 'Linux' ]]; then
  # 这个命令构建了一个镜像
  # Dockerfile 是一个用来构建镜像的文本文件，文本内容包含了一条条构建镜像所需的指令和说明。
  # nginx:v3（镜像名称:镜像标签）最后的 . 代表本次执行的上下文路径 最后一个 . 是上下文路径
  # docker build -f  Dockerfile.Linux -t fmy1993/BCexplorer-application:v1 .
  docker build -f  Dockerfile.Linux -t togettoyou/blockchain-real-estate-application:v1 .
fi

echo "三、运行编译容器"
# docker run -it -d --name blockchain-real-estate-application fmy1993/BCexplorer-application:v1
docker run -it -d --name blockchain-real-estate-application togettoyou/blockchain-real-estate-application:v1

echo "四、拷贝容器中编译后的二进制可执行文件"
docker cp blockchain-real-estate-application:/root/application/app ./