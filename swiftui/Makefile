TTY := $(shell tty)

default: macos

.PHONY: clean macos Minimal-macos.app ios Minimal-ios.app tvos Minimal-tvos

clean:
	rm -rf Minimal-macos.app Minimal-ios.app Minimal-tvos.app

macos: Minimal-macos.app
	open --stdout $(TTY) --stderr $(TTY) Minimal-macos.app

Minimal-macos.app: Minimal-macos.app/Contents/MacOS/app

Minimal-macos.app/Contents/MacOS/app: main.swift
	mkdir -p Minimal-macos.app/Contents/MacOS
	cp Info.plist Minimal-macos.app/Contents/
	swiftc \
		-parse-as-library \
		-o $@ $^

ios: Minimal-ios.app iossimulator_id
	xcrun simctl boot    $(shell cat iossimulator_id) || true
	xcrun simctl install $(shell cat iossimulator_id) Minimal-ios.app
	xcrun simctl launch --stderr=$(TTY) --stdout=$(TTY) $(shell cat iossimulator_id) minimal

Minimal-ios.app: Minimal-ios.app/app

Minimal-ios.app/app: main.swift
	mkdir -p Minimal-ios.app
	cp Info.plist Minimal-ios.app/
	swiftc \
		-sdk $(shell xcrun --sdk iphonesimulator --show-sdk-path) \
		-target arm64-apple-ios14.0-simulator \
		-parse-as-library \
		-o $@ $^

iossimulator_id:
	xcrun simctl create 'iPhone' 'iPhone 13' > $@

tvos: Minimal-tvos.app tvossimulator_id
	xcrun simctl boot    $(shell cat tvossimulator_id) || true
	xcrun simctl install $(shell cat tvossimulator_id) Minimal-tvos.app
	xcrun simctl launch --stderr=$(TTY) --stdout=$(TTY) $(shell cat tvossimulator_id) minimal

Minimal-tvos.app: Minimal-tvos.app/app

Minimal-tvos.app/app: main.swift
	mkdir -p Minimal-tvos.app
	cp Info.plist Minimal-tvos.app/
	swiftc \
		-sdk $(shell xcrun --sdk appletvsimulator --show-sdk-path) \
		-target arm64-apple-tvos14.0-simulator \
		-parse-as-library \
		-o $@ $^

tvossimulator_id:
	xcrun simctl create 'Apple TV 4K' 'Apple TV 4K' > $@
