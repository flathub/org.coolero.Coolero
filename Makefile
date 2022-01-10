.DEFAULT_GOAL := standard
ID := org.coolero.Coolero

BUILD := build
DIST := dist
REPO := $(BUILD)/repo

.PHONY: standard setup deps build bundle install run clean

standard: setup build bundle install

deps:
	@python3 flatpak-builder-tools/pip/flatpak-pip-generator --requirements-file=./requirements.txt --output pypi-dependencies
	@rm py-dependencies.yaml
	@python3 flatpak-builder-tools/flatpak-json2yaml.py pypi-dependencies.json -o py-dependencies.yaml && \
		rm pypi-dependencies.json
	@echo "Converted to yaml at py-dependencies.yaml"

setup:
	@flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	@flatpak install --system -y flathub org.flatpak.Builder org.kde.Sdk//6.2 org.kde.Platform//6.2 org.freedesktop.Sdk.Extension.llvm12//21.08

build:
	@flatpak run org.flatpak.Builder --force-clean --repo=$(REPO) $(BUILD) $(ID).yaml
	@flatpak build-update-repo $(REPO)

bundle:
	@flatpak build-bundle $(REPO) coolero.flatpak $(ID)

install:
	@flatpak install --system coolero.flatpak

run:
	@flatpak run $(ID) --debug

# this will cause the build to completely start over and take a long time, but is sometimes required after changes
clean:
	@rm -rf build/
	@rm -rf .flatpak-builder/
	@flatpak remove $(ID)