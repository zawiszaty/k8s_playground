package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func homePage(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Author micoservice")
}

func main() {
	myRouter := mux.NewRouter()
	myRouter.PathPrefix("/").HandlerFunc(homePage)
	fmt.Println("Serverd runing on port 127.0.0.1:80")
	log.Fatal(http.ListenAndServe(":80", myRouter))
}
