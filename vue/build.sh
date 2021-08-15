#!/bin/bash

echo "一、清理环境、删除旧容器"
rm -rf dist
docker rm -f blockchain-real-estate-vue

echo "二、开始打包编译"
docker build -t fmy1993/BCexplorer-vue:v1 .

echo "三、运行编译容器"
docker run -it -d --name blockchain-real-estate-vue fmy1993/BCexplorer-vue:v1

echo "四、拷贝容器中编译后的dist资源并放到application目录下"
docker cp blockchain-real-estate-vue:/root/vue/dist ./../application/dist
