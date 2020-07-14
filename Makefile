.PHONY: test clean

test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

clean:
	cd infrastructure && \
	terraform destroy
	rm -f init.done deploy.done getUser.zip getUser

init.done:
	cd infrastructure && \
	terraform init
	touch $@

deploy.done: init.done infrastructure/main.tf api/getUser.zip
	cd infrastructure && \
	terraform apply
	touch $@

getUser.zip: api/getUser
	zip $@ $<

getUser: main.go
	go get .
	GOOS=linux GOARCH=amd64 go build -o $@