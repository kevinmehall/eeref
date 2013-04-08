PATH := node_modules/.bin/:${PATH}

SRC = $(wildcard client/*/*.coffee) $(wildcard client/*.coffee)
CSS = $(wildcard client/*/*.css) $(wildcard client/*.css)

build: components $(SRC) $(CSS)
	@component build --dev --use component-coffee

components: component.json
	@component install --dev

clean:
	rm -fr build components
.PHONY: clean
