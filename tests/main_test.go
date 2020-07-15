package tests

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"testing"
)

type User struct {
	Email string `json:"email"` // if you are using a user system that has a different name, feel free to change this line
	HogwartsHouse string `json:"hogwartsHouse"`
	UpdatedAt string `json:"updatedAt"`
}

var userURL string
var authHeader string

func TestUpdate(t *testing.T) {
	u := os.Getenv("CHALLENGE_URL")
	if len(u) < 4 {
		t.Error("No CHALLENGE_URL from environment variable")
	}
	authHeader = os.Getenv("AUTH_HEADER")
	if len(authHeader) < 4 {
		t.Error("No AUTH_HEADER from environment variable")
	}
	userURL = fmt.Sprintf("https://%s/v1/users", u)
	httpClient := http.Client{}
	body := map[string]interface{}{
		"hogwartsHouse": "Gryffindor",
		"lastUpdated":  "2020-04-14T13:13:13+00:00",
	}
	messageBody, err := json.Marshal(body)
	if err != nil {
		t.Log(err)
		t.Fail()
	}

	buffer := bytes.NewBuffer(messageBody)

	req, err := http.NewRequest("PUT", userURL, buffer)
	if err != nil {
		t.Error(err)
	}

	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")

	res, err := httpClient.Do(req)
	if err != nil {
		t.Error(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		t.Error("Status code not equal to 200")
	}
	resBody, err := ioutil.ReadAll(res.Body)
	if err != nil {
		t.Error(err)
	}
	response := &User{}
	err = json.Unmarshal(resBody, response)
	if err != nil {
		t.Error(err)
	}
	if len(response.Email) < 3 {
		t.Error("Invalid email")
	}
	if response.HogwartsHouse != "Gryffindor" {
		t.Errorf("No hogwartsHouse returned: expected %s but received %s", "Gryffindor", response.HogwartsHouse)
	}
	if response.UpdatedAt != "2020-04-14T13:13:13+00:00" {
		t.Errorf("Invalid updatedAt value: expected %s but received %s", "2020-04-14T13:13:13+00:00", response.UpdatedAt)
	}
}

func TestGet(t *testing.T) {
	u := os.Getenv("CHALLENGE_URL")
	if len(u) < 4 {
		t.Error("No CHALLENGE_URL from environment variable")
	}
	authHeader = os.Getenv("AUTH_HEADER")
	if len(authHeader) < 4 {
		t.Error("No AUTH_HEADER from environment variable")
	}
	userURL = fmt.Sprintf("https://%s/v1/users", u)
	httpClient := http.Client{}

	req, err := http.NewRequest("GET", userURL, nil)
	if err != nil {
		t.Error(err)
	}

	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")

	res, err := httpClient.Do(req)
	if err != nil {
		t.Error(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		t.Error("Status code not equal to 200")
	}
	resBody, err := ioutil.ReadAll(res.Body)
	if err != nil {
		t.Error(err)
	}
	response := &User{}
	err = json.Unmarshal(resBody, response)
	if err != nil {
		t.Error(err)
	}
	if len(response.Email) < 3 {
		t.Error("Invalid email")
	}
}
