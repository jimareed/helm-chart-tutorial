package main

import (
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/items", items)
	http.HandleFunc("/count", count)
	http.ListenAndServe(":8080", nil)
}

func items(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "[{\"item\":\"apple\"}, {\"item\":\"orange\"}, {\"item\":\"pear\"}]\n")
}

func count(w http.ResponseWriter, r *http.Request) {

	req, err := http.NewRequest("GET", "http://items-chart/items", nil)
	if err != nil {
		io.WriteString(w, "[{\"error\":\"newrequest\"}]\n")
		return
	}
	client := &http.Client{}

	// Send the request via a client
	// Do sends an HTTP request and
	// returns an HTTP response
	resp, err := client.Do(req)
	if err != nil {
		io.WriteString(w, "[{\"error\":\"do\"}]\n")
		return
	}

	// Callers should close resp.Body
	// when done reading from it
	// Defer the closing of the body
	defer resp.Body.Close()

	io.WriteString(w, "[{\"count\":\"1\"}]\n")
}
