default: run

.PHONY: clean run
clean:
	rm -rf Minimal.app

SDK := macosx
SDKROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)
TTY := $(shell tty)

Minimal.app: Minimal.app/Contents/MacOS/Minimal
Minimal.app/Contents/MacOS/Minimal: main.m
	mkdir -p Minimal.app/Contents/MacOS
	cp Info.plist Minimal.app/Contents/
	clang -isysroot $(SDKROOT) \
		-framework Foundation \
		-framework AppKit \
		-o $@ $^

run: Minimal.app
	open --stdout $(TTY) --stderr $(TTY) Minimal.app
