/*
 * @Descripttion:
 * @version:
 * @Author: fmy1993
 * @Date: 2021-08-15 15:15:40
 * @LastEditors: fmy1993
 * @LastEditTime: 2021-09-13 16:56:17
 */
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/fmy1993/BCexplorer/application/blockchain"
	_ "github.com/fmy1993/BCexplorer/application/docs"
	"github.com/fmy1993/BCexplorer/application/pkg/setting"
	"github.com/fmy1993/BCexplorer/application/routers"
	"github.com/fmy1993/BCexplorer/application/service"
	"github.com/gin-gonic/gin"
)

func init() {
	setting.Setup()
}

// @title 基于区块链技术的农产品溯源系统api文档
// @version 1.0
// @description 基于区块链技术的农产品溯源系统api文档
// @contact.name fmy
// @contact.email 1390167880@qq.com
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
func main() {
	timeLocal, err := time.LoadLocation("Asia/Chongqing")
	if err != nil {
		log.Printf("时区设置失败 %s", err)
	}
	time.Local = timeLocal
	blockchain.Init()
	go service.Init()
	gin.SetMode(setting.ServerSetting.RunMode)
	routersInit := routers.InitRouter()
	readTimeout := setting.ServerSetting.ReadTimeout
	writeTimeout := setting.ServerSetting.WriteTimeout
	endPoint := fmt.Sprintf(":%d", setting.ServerSetting.HttpPort)
	maxHeaderBytes := 1 << 20

	server := &http.Server{
		Addr:           endPoint,
		Handler:        routersInit,
		ReadTimeout:    readTimeout,
		WriteTimeout:   writeTimeout,
		MaxHeaderBytes: maxHeaderBytes,
	}

	log.Printf("[info] start http server listening %s", endPoint)

	if err := server.ListenAndServe(); err != nil {
		log.Printf("start http server failed %s", err)
	}
}
