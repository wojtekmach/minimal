default: simulator

.PHONY: clean _build/Minimal.app simulator

clean:
	rm -rf Minimal.app

SDK := iphonesimulator
SDKROOT := $$(xcrun --sdk $(SDK) --show-sdk-path)

ifeq ($(shell arch),arm64)
	ARCH := aarch64
else
	ARCH := x86_64
endif

_build/Minimal.app:
	rm -rf Minimal.app
	mkdir -p Minimal.app
	MIX_ENV=prod mix release --overwrite
	cp Info.plist Minimal.app/
	cp _build/prod/app-iossimulator-$(ARCH)/bin/app Minimal.app/app
	cp -R _build/prod/app-iossimulator-$(ARCH)/rel Minimal.app/

simulator: _build/Minimal.app _build/simulator_id
	device=$$(cat _build/simulator_id) ;\
	tty=$$(tty) ;\
	xcrun simctl boot    $${device} || true ;\
	xcrun simctl install $${device} Minimal.app ;\
	xcrun simctl launch --stderr=$${tty} --stdout=$${tty} $${device} minimal
	open -a Simulator

_build/simulator_id:
	xcrun simctl create "iPhone" "iPhone 13" > $@
