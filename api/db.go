package main

import (

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"log"
	"os"
	"time"
)

var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion(os.Getenv("AWS_REGION")))

func getItem(username string) (*user, error) {
	// Prepare the input for the query.
	input := &dynamodb.GetItemInput{
		TableName: aws.String("someTable"),
		Key: map[string]*dynamodb.AttributeValue{
			"username": {
				S: aws.String(username),
			},
		},
	}

	// Retrieve the item from DynamoDB. If no matching item is found
	// return nil.
	result, err := db.GetItem(input)
	if err != nil {
		log.Printf("ERROR: %s", err)
		return nil, err
	}
	if result.Item == nil {
		return nil, nil
	}

	u := new(user)
	err = dynamodbattribute.UnmarshalMap(result.Item, u)
	if err != nil {
		return nil, err
	}

	return u, nil
}

// Add a user record to DynamoDB.
func putItem(u *user) (*user, error) {

	lastUpdated := u.UpdatedAt
	if lastUpdated == "" {
		u.UpdatedAt = time.Now().Format(time.RFC3339)
	}
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
				S: aws.String(u.UpdatedAt),
			},
		},
	}
	_, err := db.PutItem(input)
	return u, err
}
