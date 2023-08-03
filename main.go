package main

import (
	"encoding/json"
	"net/http"
)

type Status struct {
	Message string `json:"message"`
}

func main() {
	http.HandleFunc("/check", ok)
	http.ListenAndServe(":8080", nil)
}

func ok(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	status := Status{
		Message: "alive",
	}
	json.NewEncoder(w).Encode(status)
}
