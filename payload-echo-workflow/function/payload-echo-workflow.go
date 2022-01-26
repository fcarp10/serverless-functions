package function

import (
	"bytes"
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/elastic/go-elasticsearch"
	"github.com/elastic/go-elasticsearch/esapi"
	"github.com/streadway/amqp"
)

type message struct {
	Timestamp    time.Time       `json:"event_timestamp"`
	Test         string          `json:"test"`
	Doc          json.RawMessage `json:"doc"`
	Rburl        string          `json:"rburl"`
	Exchangerb   string          `json:"exchangerb"`
	Routingkeyrb string          `json:"routingkeyrb"`
	Esurl        string          `json:"esurl"`
	Ides         string          `json:"ides"`
	Doces        string          `json:"doces"`
	Pipees       string          `json:"pipees"`
	Fsurl        string          `json:"fsurl"`
	Forwards     int             `json:"forwards"`
}

type Conn struct {
	Channel *amqp.Channel
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

	if request.Rburl != "" {
		log.Println("Forwarding data to rabbitmq: " + request.Rburl)
		rb := connecToRabbitmq(request.Rburl)
		jsonMessage := message{Timestamp: request.Timestamp, Test: request.Test, Doc: request.Doc}
		jsonData, _ := json.Marshal(jsonMessage)
		publishToRabbitmq(rb, request.Exchangerb, request.Routingkeyrb, jsonData)
	} else if request.Esurl != "" {
		log.Println("Forwarding data to elasticsearch: " + request.Esurl)
		es := connectToElasticsearch(request.Esurl)
		jsonMessage := message{Timestamp: request.Timestamp, Test: request.Test, Doc: request.Doc}
		jsonData, _ := json.Marshal(jsonMessage)
		insertDocument(es, request.Ides, request.Doces, jsonData, request.Pipees)
	} else if request.Fsurl != "" {
		log.Println("Forwarding data to function: " + request.Fsurl)
		if request.Forwards > 0 {
			request.Forwards = request.Forwards - 1
			jsonMessage := message{Fsurl: request.Fsurl, Timestamp: request.Timestamp, Test: request.Test, Doc: request.Doc, Forwards: request.Forwards}
			jsonData, _ := json.Marshal(jsonMessage)
			resp, err := http.Post(request.Fsurl, "application/json", bytes.NewBuffer(jsonData))
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

func connecToRabbitmq(rabbitURL string) Conn {
	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		log.Printf("Error while connecting to rabbitmq: %s", err)
	}
	ch, err := conn.Channel()
	return Conn{Channel: ch}
}

func publishToRabbitmq(conn Conn, exchange string, routingKey string, data []byte) error {
	return conn.Channel.Publish(
		exchange,
		routingKey,
		false,
		false,
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         data,
			DeliveryMode: amqp.Persistent,
		})
}

func connectToElasticsearch(url string) *elasticsearch.Client {

	cfg := elasticsearch.Config{
		Addresses: []string{url},
	}
	es, err := elasticsearch.NewClient(cfg)
	if err != nil {
		log.Printf("Error creating the elasticsearch client: %s", err)
	}
	return es
}

func insertDocument(es *elasticsearch.Client, index string, documentID string, doc json.RawMessage, pipeline string) {

	req := esapi.IndexRequest{
		Index:      index,
		DocumentID: documentID,
		Body:       strings.NewReader(string(doc)),
		Refresh:    "true",
		Pipeline:   pipeline,
	}

	res, err := req.Do(context.Background(), es)
	if err != nil {
		log.Printf("Error getting response: %s", err)
	}
	defer res.Body.Close()

	if res.IsError() {
		log.Printf("[%s] Error indexing document ID=%s", res.Status(), documentID)
	} else {
		var r map[string]interface{}
		if err := json.NewDecoder(res.Body).Decode(&r); err != nil {
			log.Printf("Error parsing the response body: %s", err)
		} else {
			// log.Printf("[%s] %s; version=%d", res.Status(), r["result"], int(r["_version"].(float64)))
		}
	}
}
