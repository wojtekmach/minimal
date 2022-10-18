SDK := macosx
SDKROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)
TTY := $(shell tty)

default: run

.PHONY: clean run Minimal.app

clean:
	rm -rf Minimal.app

Minimal.app: Minimal.app/Contents/MacOS/Minimal

Minimal.app/Contents/MacOS/Minimal: main.m
	mkdir -p Minimal.app/Contents/MacOS
	cp Info.plist Minimal.app/Contents/
	clang -isysroot $(SDKROOT) \
		-framework AppKit \
		-o $@ $^

run: Minimal.app
	open --stdout $(TTY) --stderr $(TTY) Minimal.app
