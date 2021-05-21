module handler

go 1.15

replace handler/function => ./

require (
	github.com/elastic/go-elasticsearch/v8 v8.0.0-20210519083322-55daf7425ecb
	github.com/openfaas/templates-sdk v0.0.0-20200723092016-0ebf61253625
)
