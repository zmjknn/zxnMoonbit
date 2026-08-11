.PHONY: build test check fmt-check bench cli-smoke

build:
	moon build

test:
	moon test

check:
	moon check --deny-warn

fmt-check:
	moon fmt --check

bench:
	moon bench

cli-smoke:
	moon run src/cli -- --help
