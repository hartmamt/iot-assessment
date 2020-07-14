package main

import (
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	//"encoding/json"
	"log"
	"net/http"
	"os"
)

var errorLogger = log.New(os.Stderr, "ERROR ", log.Llongfile)

type user struct {
	Email         string        `json:"email"`
	HogwartsHouse string `json:"hogwartsHouse"`
	UpdatedAt     string     `json:"lastUpdated"`
	UserName string `json:"username"`
}

func IsValidHogwartsHouse(house string) bool {
	switch house {
	case
		"Gryffindor",
		"Slytherin",
		"Ravenclaw",
		"Hufflepuff":
		return true
	}
	return false
}

func handleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "GET":
		return show(req)
	case "PUT":
		return create(req)
	default:
		log.Printf("method not found:  %#v \n", req.HTTPMethod)
		return clientError(http.StatusMethodNotAllowed)
	}
}

// The input type and the output type are defined by the API Gateway.
func show(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	cognitouser := fmt.Sprintf("%v", req.RequestContext.Authorizer["claims"].(map[string]interface{})["cognito:username"])

	u, err := getItem(cognitouser)

	js, err := json.Marshal(u)

	if err != nil {
		return serverError(err)
	}

	res := events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json; charset=utf-8"},
		Body:       string(js),
	}
	return res, nil
}

func create(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if req.Headers["content-type"] != "application/json" && req.Headers["Content-Type"] != "application/json" {
		return clientError(http.StatusNotAcceptable)
	}

	putUser := new(user)

	err := json.Unmarshal([]byte(req.Body), putUser)

	if err != nil {
		log.Printf("unmarshal err:  %#v \n", err)
	}

	if err != nil {
		return clientError(http.StatusUnprocessableEntity)
	}

	if !IsValidHogwartsHouse(string(putUser.HogwartsHouse)){
		return clientError(http.StatusBadRequest)
	}

	if putUser.UserName=="" {
		return clientError(http.StatusBadRequest)
	}

	err = putItem(putUser)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 201,
		Headers:    map[string]string{"Location": fmt.Sprintf("/user?username=%s", putUser.UserName)},
	}, nil
}

func serverError(err error) (events.APIGatewayProxyResponse, error) {
	errorLogger.Println(err.Error())

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,

		Body:       http.StatusText(http.StatusInternalServerError),
	}, nil
}

func clientError(status int) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: status,
		//Body:       "testing",

		Headers:    map[string]string{"Content-Type": "text/plain; charset=utf-8"},
		Body:       string(http.StatusText(status)),
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
