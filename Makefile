.PHONY: build js css

all: .deps build

build:
	grunt --no-color

js:
	grunt --no-color js

css:
	grunt --no-color css

gem_modules:
	gem install sass listen compass guard

.deps:
	git submodule init
	git submodule update
	npm install --quiet
	touch .deps

sass:
	sass --compass --update css

sass-updater:
	sass --compass -q --debug-info --watch css &

clean:
	rm -rf compiled/ .sass-cache/ .deps
