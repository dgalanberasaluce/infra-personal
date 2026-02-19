TF_ENGINE:=opentofu

ifeq ($(TF_ENGINE), terraform)
  TF_BINARY:=terraform
else ifeq ($(TF_ENGINE), opentofu)
  TF_BINARY:=tofu
endif

.PHONY: all format document lint

all: help

## format: Rewrite all tf configuration files to a canonical format
format:
	$(TF_BINARY) fmt -recursive .

## document: Generate documentation from terraform module. It is configured in .terraform-docs.yml
document:
	terraform-docs -c .terraform-docs.yml .

## lint: Find errors, enforce best practices, and check for naming conventions
lint:
	tflint --init
	tflint

## help: Displays this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'