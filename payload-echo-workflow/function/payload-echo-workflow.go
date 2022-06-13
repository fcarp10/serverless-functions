package function

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type message struct {
	Doc    json.RawMessage `json:"doc"`
	Dsturl string          `json:"dsturl"`
	Length int             `json:"length"`
}

func ConvertJson(jsonM string) message {

	var message message
	err := json.Unmarshal([]byte(jsonM), &message)
	if err != nil {
		log.Fatalf("Error occurred when unmarshaling. Error: %s", err.Error())
	}
	return message
}

func ProcessRequest(data string) string {
	request := ConvertJson(data)

	if request.Dsturl != "" {
		log.Println("Forwarding data to function: " + request.Dsturl)
		if request.Length > 0 {
			request.Length = request.Length - 1
			jsonMessage := message{Dsturl: request.Dsturl, Doc: request.Doc, Length: request.Length}
			jsonData, _ := json.Marshal(jsonMessage)
			resp, err := http.Post(request.Dsturl, "application/json", bytes.NewBuffer(jsonData))
			if err != nil {
				log.Fatalf("HTTP Error response. Error: %s", err)
			}
			defer resp.Body.Close()
			body, err := ioutil.ReadAll(resp.Body)
			if err != nil {
				print(err)
			}
			return string(body)
		}
	} else {
		log.Println("No test specified, just returning data")
	}
	return data
}
