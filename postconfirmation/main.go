package main

import (
	"log"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"time"
)

// Establish DynamoDB connection
var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion(os.Getenv("AWS_REGION")))

// User defines the Cognito User and its JSON representation
type User struct {
	Email         string        `json:"email"`
	HogwartsHouse string `json:"hogwartsHouse"`
	UpdatedAt     string     `json:"updatedAt"`
	UserName string `json:"username"`
}

// putItem adds/updates a User record in DynamoDB.
func putItem(u *User) error {
	input := &dynamodb.PutItemInput{
		TableName: aws.String("someTable"),
		Item: map[string]*dynamodb.AttributeValue{
			"username": {
				S: aws.String(u.UserName),
			},
			"hogwartsHouse": {
				S: aws.String(string(u.HogwartsHouse)),
			},
			"email": {
				S: aws.String(u.Email),
			},
			"updatedAt": {
				S: aws.String(strings.Replace(time.Now().Format(time.RFC3339),"Z","+00:00",-1)),
			},
		},
	}
	_, err := db.PutItem(input)
	return err
}

// Handler uses the postConfirmation event from Cognito to PUT the User and attributes
// into the database
func Handler(event events.CognitoEventUserPoolsPostConfirmation) (events.CognitoEventUserPoolsPostConfirmation, error) {

	//Populate User with UserName and email from the Cognito event's User attributes
	putUser := new(User)
	putUser.UserName = event.UserName
	putUser.Email = event.Request.UserAttributes["email"]

	//Put User into database
	err := putItem(putUser)

	if err != nil {
		log.Printf("db err:  %#v \n", err)
	}

	return event, nil
}

func main() {
	lambda.Start(Handler)
}