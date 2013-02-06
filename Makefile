JS_DIR=files/js
DART_SRC=$(JS_DIR)/app.dart
JS_SRC=$(DART_SRC).js

all: $(JS_SRC)

$(JS_SRC): $(DART_SRC)
	$$DART_SDK/bin/dart2js -o$@ $<
	yui-compressor --line-break 120 -o $@ $@ || true

deploy:
	./deploy.sh
