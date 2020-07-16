.PHONY: test clean

test: deploy.done
	#curl -fsSL -D - "$$(terraform output url)"

clean:
	terraform destroy
	rm -f init.done deploy.done

init.done:
	terraform init
	touch $@

deploy.done: init.done main.tf ../src/lambdas/userAPI/getUser.zip ../src/lambdas/postConfirmation/postConfirmation.zip
	terraform apply
	touch $@
