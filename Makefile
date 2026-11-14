.PHONY: fmt check

fmt:
	terraform fmt -recursive

check:
	./scripts/check.sh
