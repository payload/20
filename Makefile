PROJECT = highscore-server
BUILD_PATH = build
COFFEE = $(wildcard src/*.coffee)
JS = $(wildcard src/*.js)
BUILD = $(wildcard $(BUILD_PATH)/*)
PROJECTJS = $(BUILD_PATH)/$(PROJECT).js

compile: $(PROJECTJS)

$(PROJECTJS): $(COFFEE) $(JS)
	mkdir -p $(BUILD_PATH)
	rm -f $(PROJECTJS)
	if [ "$(JS)" ]; then echo "\n// copied JavaScripts\n" >> $(PROJECTJS); cat $(JS) >> $(PROJECTJS); fi
	echo "\n// generated from CoffeeScripts\n" >> $(PROJECTJS)
	coffee -jpb $(COFFEE) >> $(PROJECTJS)

clean: $(BUILD)
	rm -f $?

