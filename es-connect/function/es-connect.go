package main

import (
	"log"

	"github.com/elastic/go-elasticsearch/v8"
)

type content struct {
	Url string
}

func ProcessRequest(data string) string {

	return data
}

func InsertDocument() {

}

func RetrieveDocument() {

}

func main() {
	cfg := elasticsearch.Config{
		Addresses: []string{"http://localhost:9200"},
	}

	es, err := elasticsearch.NewClient(cfg)
	if err != nil {
		log.Fatalf("Error creating the client: %s", err)
	}

	res, err := es.Info()
	if err != nil {
		log.Fatalf("Error getting response: %s", err)
	}

	defer res.Body.Close()
	log.Println(res)
}
