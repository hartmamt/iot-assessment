.PHONY: test clean

userAPI.zip: userAPI
	zip $@ $<

userAPI: main.go db.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@

