module handler

go 1.15

replace handler/function => ./

require (
	github.com/nats-io/nats.go v1.11.0 // indirect
	github.com/openfaas/templates-sdk v0.0.0-20200723092016-0ebf61253625
)
