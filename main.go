package main

import (
	"io"
	"net/http"
)

func test(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "[{\"count\":\"4\"}]")
}

func main() {
	http.HandleFunc("/test", test)
	http.ListenAndServe(":8080", nil)
}
