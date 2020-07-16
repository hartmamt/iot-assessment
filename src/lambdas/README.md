# Lambdas
This solution uses the Lambda service by AWS.

### User API
The userAPI Lambda is connected to the AWS API Gateway and handles GET and PUT HTTM methods.

### Post Confirmation

postConfirmation Lambda is used by Cognito in the Post Confirmation Trigger to add user attributes to DynamoDB once the user has signed up
and confirmed their email address.