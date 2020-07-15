.PHONY: test clean

postConfirmation.zip: bin/postConfirmation
	zip bin/$@ $<

bin/postConfirmation: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@

