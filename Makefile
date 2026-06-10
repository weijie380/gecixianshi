.PHONY: build install run dmg clean open help version

PROJECT_NAME = boringNotch
SCHEME = boringNotch
CONFIGURATION = Release
BUILD_DIR = build
ARCHIVE_PATH = $(BUILD_DIR)/$(PROJECT_NAME).xcarchive
APP_PATH = $(BUILD_DIR)/$(CONFIGURATION)/$(PROJECT_NAME).app
DMG_PATH = $(BUILD_DIR)/$(CONFIGURATION)/$(PROJECT_NAME).dmg
DMG_SCRIPT = Configuration/dmg/create_dmg.sh

VERSION := $(shell xcrun xcodebuild -project $(PROJECT_NAME).xcodeproj -showBuildSettings -scheme $(SCHEME) 2>/dev/null | grep MARKETING_VERSION | head -1 | awk '{print $$NF}')

# Default target
help:
	@echo "Boring Notch - Build & Install"
	@echo "=============================="
	@echo "  make build     - Build the app (Release)"
	@echo "  make install   - Build and copy to /Applications"
	@echo "  make run       - Build and launch the app"
	@echo "  make dmg       - Build and create DMG installer"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make open      - Open project in Xcode"
	@echo "  make version   - Show version info"

# Build the app
build:
	@echo "Building $(PROJECT_NAME)..."
	xcodebuild -project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(BUILD_DIR)/DerivedData \
		-destination "generic/platform=macOS" \
		CODE_SIGN_STYLE=Automatic \
		CODE_SIGN_IDENTITY="-" \
		DEVELOPMENT_TEAM="" \
		build
	@echo "Done! App built at: $(APP_PATH)"

# Build and install to /Applications
install: build
	@echo "Installing to /Applications..."
	@if [ -d "/Applications/$(PROJECT_NAME).app" ]; then \
		echo "Removing old version..."; \
		rm -rf "/Applications/$(PROJECT_NAME).app"; \
	fi
	cp -R "$(APP_PATH)" /Applications/
	@echo "Installed! Run from /Applications or use: make run"

# Build and run the app
run: build
	@echo "Launching $(PROJECT_NAME)..."
	open "$(APP_PATH)"

# Build and create DMG installer
dmg: build
	@echo "Creating DMG..."
	@if [ ! -f "$(DMG_SCRIPT)" ]; then \
		echo "Error: DMG script not found at $(DMG_SCRIPT)"; \
		exit 1; \
	fi
	@command -v dmgbuild >/dev/null 2>&1 || { \
		echo "dmgbuild not found. Install with: pip3 install dmgbuild"; \
		exit 1; \
	}
	bash "$(DMG_SCRIPT)" \
		"$(APP_PATH)" \
		"$(DMG_PATH)" \
		"$(PROJECT_NAME) $(VERSION)"
	@echo "DMG created at: $(DMG_PATH)"

# Clean build artifacts
clean:
	rm -rf "$(BUILD_DIR)"
	@echo "Cleaned."

# Open project in Xcode
open:
	open "$(PROJECT_NAME).xcodeproj"

# Show version
version:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Build: $$(xcrun xcodebuild -project $(PROJECT_NAME).xcodeproj -showBuildSettings -scheme $(SCHEME) 2>/dev/null | grep CURRENT_PROJECT_VERSION | head -1 | awk '{print $$NF}')"
