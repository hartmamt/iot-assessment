.PHONY: test clean

test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

clean:
	terraform destroy
	rm -f init.done deploy.done

init.done:
	terraform init
	touch $@

deploy.done: init.done main.tf ../api/bin/getUser.zip ../postconfirmation/bin/postConfirmation.zip
	terraform apply
	touch $@
