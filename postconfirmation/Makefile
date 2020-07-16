.PHONY: test clean

postConfirmation.zip: postConfirmation
	zip $@ $<

postConfirmation: main.go db.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@

