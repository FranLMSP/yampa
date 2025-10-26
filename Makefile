lint:
	./scripts/lint.sh

lint-all:
	flutter analyze

FILE ?= .
format:
	dart format $(FILE)
