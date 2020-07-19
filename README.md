# Platform Assessment

Challenge API URL
- https://9otfm6fbb1.execute-api.us-east-2.amazonaws.com/v1/users

User sign up URL
- https://hogwarts1.auth.us-east-2.amazoncognito.com/login?client_id=6g9agk3ovdpv56vkqi2ri0j5l9&response_type=token&scope=email+openid&redirect_uri=https://hogwarts-demos3staticweb.s3.us-east-2.amazonaws.com/index.html


### Overview

First, I wanted to say thank you so much for the opportunity to work on this challenge.  It is the funnest
interview question I've ever had. :) I'm excited for the opportunity to walk through what I've done, including
my thought process and challenges I faced along the way.

### Approach

My approach was geared towards two things, using a stack that is as close to what P&G is using as possible and 
pass the test results without adding any more technology than required. 

- **Auth System** - I chose Cognito because is tightly integrated with other AWS services I planned on using. I also 
knew that the team used Cognito and would be able to help if I had any questions. Cognito worked very well for this
project! Some of my favorite things with Cognito included
    - The Hosted UI removed the need for a front end application with the exception of a simple static HTML file that
    I used to display the Authorization Token to make it easy to generate the Authorization header.
    - I wanted to automatically store the user in the database on confirmation. Using Cognito's trigger for post
    confirmation made it super easy to do this!
- **API Gateway** - For the API gateway I again chose to stay with the AWS stack. I had never used this product before so
it was also something I was excited to dig into.  
    - This felt like a perfect choice because I really wanted to use Lambdas as part of the API, setting this up with
    Terraform was really fun.  Being able to simple declare an API with various resources and see it built out was
    pretty amazing.
- **Persistence** - I chose DynamoDB for storing the user attributes. I made this decision not only because it is part of the same
AWS stack but also because it is a technology that I know the team uses.  I haven't had a chance to use DynamoDB before 
but found it pretty straight forward.
- **Golang and Lambdas** - Having only played around with Lambdas a long time ago while trying to make an Alexa skill, I was
really excited to get into them again.  I also chose Golang as my development language so I would have a chance to dig
more into the syntax and using it in a more real world situation.  Most of my recent experience has been using Javascript
so it was definitely a treat switching to Golang!
    - I loved using Goland for an IDE.  It had a lot of great tools built in and definitely felt like a step up for this
    use case over Visual Studio Code.
    - I felt like I was able to write more concise and simple code and appreciated that the compiler forced you to remove
    any variables or imports that weren't used.  
    - Coding without try..catch was really interesting. I thought it was an odd design decision for a language until I read several articles
    talking about how it forces developers to handle every error instead of writing generic handling code for a block.
    - I definitely have a lot more to learn but was able to find good guides and tutorials to get the job done.
    - Lambdas are awesome.  I loved not having to have my code coupled in with my node js service (express or hapijs).
- **Web Front End** - I only needed a static HTML page for the Cognito hosted UI to redirect a user to after sign in / sign
up.  I used Cloudfront for hosting and S3 for the static html / css storage.  I wrote some simple Javascript to grab the
ID_TOKEN out of the URL and displayed it in an HTML TextArea that automatically does a select all when clicked.  The
purpose of this was just to make a simple way to copy the ID_Token used for the authentication header when making API calls.
    
### Challenges

The biggest challenge for me was mostly learning how all the AWS pieces fit together. Having a background in IAM, databases, and middleware was helpful and once I dug more into the stack things seemed to fall into place.

Golang is fairly new to me as a language so I did have to spend a fair amount of time reading blog posts and going through Stackoverflow questions. I felt the community was helpful and it was not difficult to find the answers to my questions. I definitely would like to spend more time learning the specifics of Golang but I felt like I was able to get the basic use case done. I have lots of questions and would love feedback on any places in my code that could use improving for either performance or readability.


# Original README starts here

### Contents
- [Welcome](#welcome)
- [The Platform Team](#the-platform-team)
- [Success in Role](#success-in-this-role)
- [Challenge](#challenge)



# Welcome 
😀
If you are reading this, congratulations you are a candidate for the platform team!

We are so glad you are here and can't wait to find out if our team and this work is a great fit for you and the team.

This repo is designed to help us determine the technical part of that.

# The Platform Team
Our team is made up of "hands on keyboard" folks and each member is expected to wear multiple hats.

Our scope is to build a globally scalable IoT solution that meets local regulations, security compliance,
ultra high performance and uptime, and enables brands to build world class device experiences.

This team will be high challenge and high growth, and requires great time management to make your 40 hours count.

## Team Values
- We are big believers in P&G's [PVP](https://us.pg.com/policies-and-practices/purpose-values-and-principles/), and proud to practice them
- Kindness and honesty, your co-workers and partners are human beings.
- Always learning(curiousity), most team members pair program 10-25% of the time, 
 every deliverable is an opportunity to feed into team knowledge.
 - Ownership, you are given areas of responsibility and expected to own those areas. Pushing excellence and asking for help when needed.
 
If you strongly disagree with any of the above, you likely won't be happy on our team. No hard feelings!

# Success in this role
🚀
Being 'M' Shaped or full stack.  If you've heard of ['T-Shaped'](https://chiefexecutive.net/ideo-ceo-tim-brown-t-shaped-stars-the-backbone-of-ideoaes-collaborative-culture__trashed/), this builds on the idea of being collaborative across disciplines but also build a depth of skill in not one but many different areas.

![m shaped](images/m_shaped.png "M shaped diagram")

Our stack comprises [golang](https://golang.org/) services, 100% infrastructure as code with [terraform](https://www.terraform.io/docs/providers/aws/index.html), running in [AWS](https://aws.amazon.com), with dashboards in [vue.js](https://vuejs.org/). If you haven't heard of any or all of these, that's ok!

On our team you will be given a lot of autonomy and freedom, but ownership of deliverables is expected.
Problem domains will be lightly defined and you will be expected to dig, challenge and be challenged by yourself/teammates/vendors/users/etc., and push to deliver excellent solutions.

This work style isn't for everyone, and that's ok!


 
 # Challenge
 🏂
 We provide you the following:
 - An AWS account to test with
 - As much time as you need (most folks return this within a 1-2 weeks and spend between 2-4 hours)
 - An open back and forth with any questions or concerns you have
 
 ## Success looks like the following:
 - You'll need an auth system, you get to choose here. You can go with a SAAS offering (Cognito, Auth0, Okta) or build your own. Must support Token or Basic Auth.
 - Build two (2) API endpoints. You can build these on whatever compute you choose with any supported language, lambda, fargate, EC2. You choose! (for reference we like Go with Lambda)
    - Endpoint 1: PUT updateUser, with the following custom attributes.
        - Hogwarts house in camelCase (hogwartsHouse), a string / enum value with options of (Gryffindor, Slytherin, Ravenclaw, Hufflepuff)
        - Updated at in [ISO-8601](https://en.wikipedia.org/wiki/ISO_8601) Datetime camelCase (updatedAt), a string date format. (for reference we like 2020-04-14T13:13:13+00:00)
        - Where you store these attributes is up to you: SQL database for user metadata, redis, inside the auth system if supported. All acceptable choices, just be prepared to answer the 'why?'
   - Endpoint 2: GET getUser and will return email, hogwartsHouse, and lastUpdated
- Both of these need to live at https://YOURURL/api/v1/users and should return a status code of 200 along with the 3 attributes
- All (or most!) of the infrastructure you provision should be deployed with terraform. This is a hard requirement.
- Set Environment variable CHALLENGE_URL to YOURURL
- Set the Environment variable AUTH_HEADER to your authorization header ("basic BASE64USERPASS==" or "bearer JWTOKEN")
- Run E2E tests in Go (regardless of what language you ran you'll need to install Go for this)
- Upload your code to a github repo and ping us with instructions on how to generate the auth header.

## Hard Rules:
- Using 3rd party libraries, google, stackoverflow, emailing questions to us for help; all perfectly acceptable and encouraged.
However you must write the code, copying gists is fine but someone else writing the code for you breaks our 'honesty' value. This needs to be your work. (Don't ask your friend to write it for you, and if you find a fork of this on the web, don't copy from it.)
- Infrastructure has to be provisioned with mostly terraform, only acceptable reasons why not will be that a terraform provider wasn't available.
- You can't change any existing code in the repo. Updating the tests to accept a 500 status code is clever... but not what we are looking for.
   
 
