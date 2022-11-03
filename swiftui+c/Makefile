TTY := $(shell tty)

default: macos

.PHONY: clean macos Minimal-macos.app

clean:
	rm -rf Minimal-macos.app Minimal-ios.app Minimal-tvos.app

macos: Minimal-macos.app
	open --stdout $(TTY) --stderr $(TTY) Minimal-macos.app

Minimal-macos.app: Minimal-macos.app/Contents/MacOS/app

hello.o: hello.c
	clang -c -o $@ $^

Minimal-macos.app/Contents/MacOS/app: main.swift hello.o
	mkdir -p Minimal-macos.app/Contents/MacOS
	cp Info.plist Minimal-macos.app/Contents/
	swiftc \
		-import-objc-header hello.h \
		-parse-as-library \
		-o $@ $^
