build:
	cd src/lambdas/userAPI/ && $(MAKE)
	cd src/lambdas/postConfirmation/ && $(MAKE)
	cd infrastructure/ && $(MAKE)
