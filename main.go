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

	req, err := http.NewRequest("GET", "http://items-chart:8080/items", nil)
	if err != nil {
		io.WriteString(w, "new request error\n")
		return
	}
	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		io.WriteString(w, "error executing request\n")
		return
	}

	defer resp.Body.Close()

	io.WriteString(w, "{\"count\":\"1\"}\n")
}
