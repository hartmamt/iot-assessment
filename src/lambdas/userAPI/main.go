package main

import (
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"log"
	"net/http"
	"os"
)

var errorLogger = log.New(os.Stderr, "ERROR", log.Llongfile)

// User defines the Cognito User and its JSON representation
type User struct {
	Email         string `json:"email"`
	HogwartsHouse string `json:"hogwartsHouse"`
	UpdatedAt     string `json:"updatedAt"`
	UserName      string `json:"username"`
}

// IsValidHogwartsHouse validates a given string against possible
// Hogwarts Houses
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

// handleRequests acts a router and passes the request to the correct
// function based on its HTTPMethod
func handleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "GET":
		return show(req)
	case "PUT":
		return update(req)
	default:
		log.Printf("method not found:  %#v \n", req.HTTPMethod)
		return clientError(http.StatusMethodNotAllowed)
	}
}

// show will use the cognito:username of the current use and return
// its House, Email, and Updated Last timestamp
func show(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	//Extract unique cognito:username claim from Request
	cognitouser := fmt.Sprintf("%v", req.RequestContext.Authorizer["claims"].(map[string]interface{})["cognito:username"])

	//Get attributes from database
	u, err := getItem(cognitouser)

	if err != nil {
		return serverError(err)
	}

	//Marshal User to JSON
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

// update will update the database with the submitted Hogwarts House.  It will set UpdatedLast to current time
// unless UpdatedLast is provided in the submitted data. If UpdatedLast is present, it will use that instead of
// current time.
func update(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// Validate that the request contains the appropriate json header
	if req.Headers["content-type"] != "application/json" && req.Headers["Content-Type"] != "application/json" {
		return clientError(http.StatusNotAcceptable)
	}

	// Unmarshal Cognito User from Request Body
	putUser := new(User)
	err := json.Unmarshal([]byte(req.Body), putUser)

	if err != nil {
		return clientError(http.StatusUnprocessableEntity)
	}

	// Username and Email should be read only, override these with values from the Claim
	putUser.UserName = fmt.Sprintf("%v", req.RequestContext.Authorizer["claims"].(map[string]interface{})["cognito:username"])
	putUser.Email = fmt.Sprintf("%v", req.RequestContext.Authorizer["claims"].(map[string]interface{})["email"])

	// Validate Hogwarts House
	if !IsValidHogwartsHouse(string(putUser.HogwartsHouse)) {
		return clientError(http.StatusBadRequest)
	}

	// Call putItem to `upsert` the User in the database
	responseUser := new(User)
	responseUser, err = putItem(putUser)

	// Marshal User to JSON
	js, err := json.Marshal(responseUser)

	if err != nil {
		return serverError(err)
	}

	// Return JSON version of User with appropriate headers
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json; charset=utf-8"},
		Body:       string(js),
	}, nil
}

func serverError(err error) (events.APIGatewayProxyResponse, error) {
	errorLogger.Println(err.Error())
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,

		Body: http.StatusText(http.StatusInternalServerError),
	}, nil
}

func clientError(status int) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: status,
		Headers:    map[string]string{"Content-Type": "text/plain; charset=utf-8"},
		Body:       string(http.StatusText(status)),
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
