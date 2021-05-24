package function

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"

	"github.com/elastic/go-elasticsearch/v8"
	"github.com/elastic/go-elasticsearch/v8/esapi"
)

type Content struct {
	Url        string
	Index      string
	DocumentID string
	Doc        json.RawMessage
	Query      json.RawMessage
}

func ConvertJson(jsonM string) Content {

	var message Content
	err := json.Unmarshal([]byte(jsonM), &message)
	if err != nil {
		log.Fatalf("Error occurred when unmarshaling. Error: %s", err.Error())
	}
	return message
}

func ProcessRequest(data string) string {
	request := ConvertJson(data)

	cfg := elasticsearch.Config{
		Addresses: []string{request.Url},
	}
	es, err := elasticsearch.NewClient(cfg)
	if err != nil {
		result := fmt.Sprintf("Error creating the client: %s", err)
		return result
	}

	if request.Doc != nil {
		return InsertDocument(es, request)
	}
	if request.Query != nil {
		return RetrieveDocument(es, request)
	}

	return "No action performed, please specify query/document"
}

func InsertDocument(es *elasticsearch.Client, content Content) string {

	req := esapi.IndexRequest{
		Index:      content.Index,
		DocumentID: content.DocumentID,
		Body:       strings.NewReader(string(content.Doc)),
		Refresh:    "true",
	}

	res, err := req.Do(context.Background(), es)
	if err != nil {
		result := fmt.Sprintf("Error getting response: %s", err)
		log.Printf(result)
		return result
	}
	defer res.Body.Close()

	if res.IsError() {
		result := fmt.Sprintf("[%s] Error indexing document ID=%s", res.Status(), content.DocumentID)
		log.Printf(result)
		return result
	} else {
		var result string
		var r map[string]interface{}
		if err := json.NewDecoder(res.Body).Decode(&r); err != nil {
			result = fmt.Sprintf("Error parsing the response body: %s", err)
		} else {
			result = fmt.Sprintf("[%s] %s; version=%d", res.Status(), r["result"], int(r["_version"].(float64)))
		}
		log.Printf(result)
		return result
	}
}

func RetrieveDocument(es *elasticsearch.Client, content Content) string {

	var buf bytes.Buffer

	if err := json.NewEncoder(&buf).Encode(content.Query); err != nil {
		log.Fatalf("Error encoding query: %s", err)
	}

	res, err := es.Search(
		es.Search.WithContext(context.Background()),
		es.Search.WithIndex(content.Index),
		es.Search.WithBody(&buf),
		es.Search.WithTrackTotalHits(true),
		es.Search.WithPretty(),
	)

	if err != nil {
		result := fmt.Sprintf("Error getting response: %s", err)
		log.Printf(result)
		return result
	}
	defer res.Body.Close()

	if res.IsError() {
		var result string
		var e map[string]interface{}
		if err := json.NewDecoder(res.Body).Decode(&e); err != nil {
			result = fmt.Sprintf("Error parsing the response body: %s", err)
		} else {
			result = fmt.Sprintf("[%s] %s: %s", res.Status(), e["error"].(map[string]interface{})["type"], e["error"].(map[string]interface{})["reason"])
		}
		log.Printf(result)
		return result
	}

	var r map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&r); err != nil {
		result := fmt.Sprintf("Error parsing the response body: %s", err)
		log.Printf(result)
		return result
	}
	result := fmt.Sprintf(
		"[%s] %d hits; took: %dms",
		res.Status(),
		int(r["hits"].(map[string]interface{})["total"].(map[string]interface{})["value"].(float64)),
		int(r["took"].(float64)),
	)
	log.Printf(result)
	for _, hit := range r["hits"].(map[string]interface{})["hits"].([]interface{}) {
		log.Printf(" * ID=%s, %s", hit.(map[string]interface{})["_id"], hit.(map[string]interface{})["_source"])
	}
	return result
}
