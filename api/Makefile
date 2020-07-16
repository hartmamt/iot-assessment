.PHONY: test clean

getUser.zip: getUser
	zip $@ $<

getUser: main.go db.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@

