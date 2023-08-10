package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

func handler(w http.ResponseWriter, r *http.Request) {
	reqBody, err := ioutil.ReadAll(r.Body)
	log.Print("received a request with message: ", string(reqBody))
	n, err := strconv.Atoi(string(reqBody))
	if err == nil {
		time.Sleep(time.Duration(n) * time.Millisecond)
		fmt.Fprintf(w, "done!")
	} else {
		fmt.Fprintf(w, "wrong input!")
	}
}

func main() {
	log.Print("starting server...")
	http.HandleFunc("/", handler)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
