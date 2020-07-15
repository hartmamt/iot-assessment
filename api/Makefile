.PHONY: test clean

getUser.zip: bin/getUser
	zip bin/$@ $<

bin/getUser: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@

