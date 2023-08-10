package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strconv"
)

func fib(n uint64) uint64 {
	if n == 1 {
		return 1
	}
	if n <= 0 {
		return 0
	}
	return fib(n-1) + fib(n-2)
}

func handler(w http.ResponseWriter, r *http.Request) {
	reqBody, err := ioutil.ReadAll(r.Body)
	log.Print("received a request with message: ", string(reqBody))
	n, err := strconv.ParseUint(string(reqBody), 10, 64)
	if err == nil {
		fmt.Fprintf(w, strconv.FormatUint(fib(n), 10))
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
