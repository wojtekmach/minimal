SDK := iphonesimulator
SDKROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)
TTY := $(shell tty)
DEVICE := 7FF0D0C0-4B89-4B78-AA59-25040F03DA02

default: run

.PHONY: clean run

clean:
	rm -rf Minimal.app

Minimal.app: Minimal.app/app

Minimal.app/app: main.m
	mkdir -p Minimal.app
	cp Info.plist Minimal.app/
	clang -isysroot $(SDKROOT) \
		-framework UIKit \
		-o $@ $^

run: Minimal.app
	xcrun simctl boot    $(DEVICE) || true
	xcrun simctl install $(DEVICE) Minimal.app
	xcrun simctl launch --stderr=$(TTY) --stdout=$(TTY) $(DEVICE) minimal
