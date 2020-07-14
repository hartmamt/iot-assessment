.PHONY: test clean

test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

clean:
	terraform destroy
	rm -f init.done deploy.done getUser.zip getUser

init.done:
	terraform init
	touch $@

deploy.done: init.done main.tf ../api/getUser.zip
	terraform apply
	touch $@
