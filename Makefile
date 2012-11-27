COFFEE_SRC = $(wildcard client/*/*.coffee) $(wildcard client/*.coffee)
SRC = $(COFFEE_SRC:.coffee=.js)
CSS = $(wildcard client/*/*.css) $(wildcard client/*.css)

build: components $(SRC) $(CSS)
	@component build --dev

components: component.json
	@component install --dev

%.js: %.coffee
	@coffee -c $<

clean:
	rm -fr build components
.PHONY: clean
