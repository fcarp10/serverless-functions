module handler

go 1.15

replace handler/function => ./

require (
	github.com/elastic/go-elasticsearch v0.0.0
	github.com/openfaas/templates-sdk v0.0.0-20200723110415-a699ec277c12
	github.com/streadway/amqp v1.0.0
)
