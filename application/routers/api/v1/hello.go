package v1

import (
	"github.com/fmy1993/BCexplorer/application/pkg/app"
	"github.com/gin-gonic/gin"
	"net/http"
)

// @Summary 测试输出Hello
// @Produce  json
// @Success 200 {object} app.Response
// @Failure 500 {object} app.Response
// @Router /api/v1/hello [get]
func Hello(c *gin.Context) {
	appG := app.Gin{C: c}
	appG.Response(http.StatusOK, "成功", map[string]interface{}{
		"msg": "Hello",
	})
}
