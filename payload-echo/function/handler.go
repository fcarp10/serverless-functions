package function

import (
	"net/http"

	handler "github.com/openfaas/templates-sdk/go-http"
)

// Handle a function invocation
func Handle(req handler.Request) (handler.Response, error) {
	var err error

	var response = ProcessRequest(string(req.Body))

	return handler.Response{
		Body:       []byte(response),
		StatusCode: http.StatusOK,
	}, err
}
