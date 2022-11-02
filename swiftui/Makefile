default: run

.PHONY: clean run Minimal.app

clean:
	rm -rf Minimal.app

Minimal.app: Minimal.app/Contents/MacOS/Minimal

Minimal.app/Contents/MacOS/Minimal: Main.swift ContentView.swift
	mkdir -p Minimal.app/Contents/MacOS
	cp Info.plist Minimal.app/Contents/
	swiftc -o $@ $^

run: Minimal.app
	open --stdout $(TTY) --stderr $(TTY) Minimal.app
