.PHONY: test clean

#test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

postConfirmation.zip: postConfirmation
	zip $@ $<

postConfirmation: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@