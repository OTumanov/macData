.PHONY: all build run test clean debug release install help

APP := build/MacDataCalendar.app
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION := $(shell /usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Sources/MacDataCalendar/Info.plist)

all: build

build:
	@bash Scripts/build-app.sh

run: build
	@open "$(APP)"

install: build
	@pkill -x MacDataCalendar 2>/dev/null || true
	@cp -R "$(APP)" /Applications/
	@open /Applications/MacDataCalendar.app
	@echo "Installed to /Applications/MacDataCalendar.app"

release:
	@bash Scripts/release.sh

test:
	swift test

debug:
	swift build

clean:
	rm -rf build .build dist

help:
	@echo "MacData Calendar v$(VERSION)"
	@echo ""
	@echo "Targets:"
	@echo "  make           Build MacDataCalendar.app (release)"
	@echo "  make run       Build and open the app"
	@echo "  make install   Build, copy to /Applications, launch"
	@echo "  make release   Build + dist/MacDataCalendar-$(VERSION).zip"
	@echo "  make test      Run unit tests (requires Xcode)"
	@echo "  make debug     Swift debug build only"
	@echo "  make clean     Remove build/, .build/, dist/"
