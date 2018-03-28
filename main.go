package main

import (
	"io"
	"net/http"
)

func stub(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "{\"count\":\"4\"}")
}

func main() {
	http.HandleFunc("/v1/collection-count", stub)
	http.ListenAndServe(":8080", nil)
}
