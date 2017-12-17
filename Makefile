include docker_make_utils/Makefile.help
SHELL := /bin/bash
.DEFAULT_GOAL := release

.PHONY: release
release:
	pandoc -t markdown -o README.md -f textile README.textile
