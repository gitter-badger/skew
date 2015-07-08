SOURCES += src/backend/*.sk
SOURCES += src/core/*.sk
SOURCES += src/frontend/*.sk
SOURCES += src/lib/timestamp.sk
SOURCES += src/lib/unicode.sk
SOURCES += src/middle/*.sk

SOURCES_NODE += $(SOURCES)
SOURCES_NODE += src/driver/node.sk
SOURCES_NODE += src/driver/options.sk
SOURCES_NODE += src/lib/io.sk
SOURCES_NODE += src/lib/terminal.sk

SOURCES_BROWSER += $(SOURCES)
SOURCES_BROWSER += src/driver/browser.sk

SOURCES_TEST += $(SOURCES)
SOURCES_TEST += src/driver/tests.sk
SOURCES_TEST += src/lib/terminal.sk
SOURCES_TEST += src/lib/unit.sk
SOURCES_TEST += tests/simple.sk

JS_FLAGS += --target=js
JS_FLAGS += --inline-functions

CS_FLAGS += --target=cs
CS_FLAGS += --inline-functions

default: compile-node compile-browser

compile-node: | build
	node skewc.js $(SOURCES_NODE) $(JS_FLAGS) --output-file=build/node.js

compile-browser: | build
	node skewc.js $(SOURCES_BROWSER) $(JS_FLAGS) --output-file=build/browser.js

replace: | build
	node skewc.js $(SOURCES_NODE) $(JS_FLAGS) --output-file=build/node.js
	node build/node.js $(SOURCES_NODE) $(JS_FLAGS) --output-file=build/node2.js
	node build/node2.js $(SOURCES_NODE) $(JS_FLAGS) --output-file=build/node3.js
	cmp -s build/node2.js build/node3.js
	mv build/node3.js skewc.js
	rm build/node2.js

watch:
	node_modules/.bin/watch src 'clear && make compile-browser'

build:
	mkdir -p build

flex:
	cd src/frontend && python build.py && cd -

test: test-js test-cs

test-js:
	node skewc.js $(SOURCES_TEST) $(JS_FLAGS) --output-file=build/test.js
	node build/test.js

test-cs:
	node skewc.js $(SOURCES_TEST) $(CS_FLAGS) --output-file=build/test.cs
	mcs -debug build/test.cs
	mono --debug build/test.exe
