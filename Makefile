include Makefile.help
SHELL := /bin/bash
.DEFAULT_GOAL := release

.PHONY: release
release:
	pandoc -t markdown_strict -o README.md -f textile README.textile
