# Utils
This folder contains two scripts that are useful for testing.  They require the installation of
HTTPie (https://httpie.org/). Installation details are available on their website.

### get.sh

This script takes an ID_TOKEN and builds a simple GET http request to the API.

`./get.sh [id_token]`

Example output

`HTTP/1.1 200 OK
 Connection: keep-alive
 Content-Length: 157
 Content-Type: application/json; charset=utf-8
 Date: Thu, 16 Jul 2020 14:38:25 GMT
 Via: 1.1 b8a96492a425c0c05d4bffe827b23ea7.cloudfront.net (CloudFront)
 X-Amz-Cf-Id: NTCLg19zvDl2JCo6ww0dS1e7XZFpfo3ZscSsqezjFcyKrCR0tBIpuA==
 X-Amz-Cf-Pop: ORD53-C3
 X-Amzn-Trace-Id: Root=1-5f106660-fe2efb7686f437fe53890678;Sampled=0
 X-Cache: Miss from cloudfront
 x-amz-apigw-id: PxTvIGstCYcFudA=
 x-amzn-RequestId: 6dc1a3ab-4e01-4a0a-b5a6-7f32a64e76db`
 `
 ```json
 {
     "email": "email@gmail.com",
     "hogwartsHouse": "Gryffindor",
     "updatedAt": "2020-07-16T14:14:06+00:00",
     "username": "d978623d-ae72-42ce-852d-2f387cf40973"
 }
```

### put.sh

This script takes a Hogwarts House and ID_TOKEN and builds a simple PUT http request to the API.

`./put.sh [Hogwarts House] [id_token]`

Example output

`HTTP/1.1 200 OK
 Connection: keep-alive
 Content-Length: 157
 Content-Type: application/json; charset=utf-8
 Date: Thu, 16 Jul 2020 14:46:34 GMT
 Via: 1.1 1a02ed973fa197a1dacf9e97520c66fa.cloudfront.net (CloudFront)
 X-Amz-Cf-Id: Pli048aEpQEHGou_Ch4v9t0gwt-_wIINSOUfobpmR9QNny80SjQeWw==
 X-Amz-Cf-Pop: ORD53-C3
 X-Amzn-Trace-Id: Root=1-5f10684a-d3b50826f5b1d9a4b82e05e8;Sampled=0
 X-Cache: Miss from cloudfront
 x-amz-apigw-id: PxU7mGE6CYcFbdA=
 x-amzn-RequestId: ea015ea1-96d8-4faa-8c8d-534beed58dca
 `
 ```json
{
    "email": "email@gmail.com",
    "hogwartsHouse": "Hufflepuff",
    "updatedAt": "2020-07-16T14:46:34+00:00",
    "username": "d978623d-ae72-42ce-852d-2f387cf40973"
}
```

