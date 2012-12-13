.PHONY: build js css

all: build stats
	# node node_modules/requirejs/bin/r.js -o js/build.js

stats:
	@stat -f "%N: %z bytes" compiled/umobi.min.js
	@stat -f "%N: %z bytes" compiled/umobi.min.css

build: js css

js:
	grunt --config Gruntfile.coffee js

css:
	grunt --config Gruntfile.coffee css

node_modules:
	npm install

gem_modules:
	gem install sass listen

deps: node_modules gem_modules

sass:
	sass -c --update css

sass-updater:
	sass -q --debug-info --watch css &
