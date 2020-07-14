.PHONY: test clean

#test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

getUser.zip: getUser
	zip $@ $<

getUser: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@