default: sim

.PHONY: clean sim
clean:
	rm -rf Minimal.app

SDK := appletvsimulator
SDKROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)
DEVICE := 1BD00DE5-CFCE-41EB-9FDA-9621E90B81C3

Minimal.app: Minimal.app/app
Minimal.app/app: main.m
	mkdir -p Minimal.app
	cp Info.plist Minimal.app/
	clang -isysroot $(SDKROOT) \
		-framework Foundation \
		-framework UIKit \
		-o $@ $^

sim: Minimal.app
	xcrun simctl boot    $(DEVICE) || true
	xcrun simctl install $(DEVICE) Minimal.app
	xcrun simctl launch  $(DEVICE) minimal
