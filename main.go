package main

import (
	"encoding/json"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
)

// ItemList : list of items
type ItemList []struct {
	Item string `json:"item"`
}

func main() {
	http.HandleFunc("/items", items)
	http.HandleFunc("/count", count)
	http.HandleFunc("/", health)
	http.HandleFunc("/health", health)
	http.ListenAndServe(":8080", nil)
}

func items(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "[{\"item\":\"apple\"}, {\"item\":\"orange\"}, {\"item\":\"pear\"}]\n")
}

func health(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "{\"message\":\"OK\"}\n")
}

func count(w http.ResponseWriter, r *http.Request) {

	url := os.Getenv("ITEMS_SERVICE_URL") + "/items"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		io.WriteString(w, url)
		io.WriteString(w, " connect error\n")
		return
	}
	client := &http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		io.WriteString(w, url)
		io.WriteString(w, " error executing request\n")
		return
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		io.WriteString(w, url)
		io.WriteString(w, " error reading response\n")
		return
	}

	var i ItemList

	err = json.Unmarshal(body, &i)
	if err != nil {
		io.WriteString(w, url)
		io.WriteString(w, " error reading response\n")
		return
	}

	s := strconv.Itoa(len(i))

	io.WriteString(w, "{\"count\":\"")
	io.WriteString(w, s)
	io.WriteString(w, "\"}\n")

}
