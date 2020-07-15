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
var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion(os.Getenv("AWS_REGION")))

type user struct {
	Email         string        `json:"email"`
	HogwartsHouse string `json:"hogwartsHouse"`
	UpdatedAt     string     `json:"updatedAt"`
	UserName string `json:"username"`
}

// Add a user record to DynamoDB.
func putItem(u *user) error {
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

func Handler(event events.CognitoEventUserPoolsPostConfirmation) (events.CognitoEventUserPoolsPostConfirmation, error) {

	email := event.Request.UserAttributes["email"]
	username := event.UserName

	putUser := new(user)
	putUser.UserName = username
	putUser.Email = email

	err := putItem(putUser)
	if err != nil {
		log.Printf("db err:  %#v \n", err)
	}

	return event, nil
}

func main() {
	lambda.Start(Handler)
}