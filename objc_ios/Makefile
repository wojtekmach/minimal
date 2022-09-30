default: sim

.PHONY: clean sim
clean:
	rm -rf Minimal.app

SDK := iphonesimulator
SDKROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)
DEVICE := 7FF0D0C0-4B89-4B78-AA59-25040F03DA02

Minimal.app: Minimal.app/app
Minimal.app/app: main.m
	mkdir -p Minimal.app
	cp Info.plist Minimal.app/
	clang -isysroot $(SDKROOT) \
		-framework Foundation \
		-framework UIKit \
		-o $@ $^

Minimal.app/echo: echo.m
	mkdir -p Minimal.app
	clang -isysroot $(SDKROOT) \
		-o $@ $^

sim: Minimal.app
	xcrun simctl boot    $(DEVICE) || true
	xcrun simctl install $(DEVICE) Minimal.app
	xcrun simctl launch --stderr=$(shell tty) --stdout=$(shell tty) $(DEVICE) minimal
