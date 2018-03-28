package main

import (
	"io"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "{\"count\":\"4\"}")
}

func main() {
	http.HandleFunc("/v1/collection-count", hello)
	http.ListenAndServe(":8080", nil)
}
