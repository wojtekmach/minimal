TTY := $(shell tty)
DEVICE := 7FF0D0C0-4B89-4B78-AA59-25040F03DA02

default: macos

.PHONY: clean macos Minimal-macos.app ios Minimal-ios.app

clean:
	rm -rf Minimal-macos.app Minimal-ios.app

Minimal-macos.app: Minimal-macos.app/Contents/MacOS/app

Minimal-macos.app/Contents/MacOS/app: Main.swift ContentView.swift
	mkdir -p Minimal-macos.app/Contents/MacOS
	cp Info.plist Minimal-macos.app/Contents/
	swiftc -o $@ $^

macos: Minimal-macos.app
	open --stdout $(TTY) --stderr $(TTY) Minimal-macos.app

Minimal-ios.app: Minimal-ios.app/app

Minimal-ios.app/app: Main.swift ContentView.swift
	mkdir -p Minimal-ios.app
	cp Info.plist Minimal-ios.app/
	swiftc \
		-sdk $(shell xcrun --sdk iphonesimulator --show-sdk-path) \
		-target arm64-apple-ios14.0-simulator \
		-o $@ $^

ios: Minimal-ios.app
	xcrun simctl boot    $(DEVICE) || true
	xcrun simctl install $(DEVICE) Minimal-ios.app
	xcrun simctl launch --stderr=$(TTY) --stdout=$(TTY) $(DEVICE) minimal
