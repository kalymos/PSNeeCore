# Makefile pour créer le core Arduino ZIP + JSON indexable par l'IDE Arduino

# ------------------- Paramètres de base -------------------

PACKAGER := kalymnos
ARCH := psneecore
CORE_NAME := PSNeeCore

BUILD_DIR := release
CORE_DIR := PSNeeCore/avr

# Si VERSION n’est pas défini en ligne de commande, on le demande à l’utilisateur
ifndef VERSION
  VERSION := $(shell read -p "Entrez le numéro de version (ex: 1.0.0) : " ver; echo $$ver)
endif

ZIP_NAME := $(ARCH)-$(VERSION).zip
ZIP_PATH := $(BUILD_DIR)/$(ZIP_NAME)
INDEX_FILE := $(BUILD_DIR)/package_$(ARCH)_index.json

# URL vers le ZIP hébergé (ex : GitHub Pages)
BASE_URL := https://kalymos.github.io/PSNeeCore/$(BUILD_DIR)/$(ZIP_NAME)

# ------------------- Règles Make -------------------

.PHONY: all clean prepare zip json

all: zip json

prepare:
	mkdir -p $(BUILD_DIR)

zip: prepare
	@echo " Création de l'archive $(ZIP_NAME) avec 'avr/' à la racine …"
	mkdir -p $(BUILD_DIR)
	cd $(CORE_DIR)/.. && zip -r "$(abspath $(ZIP_PATH))" avr


json: zip
	@echo " Génération du fichier JSON d’index pour l’IDE Arduino…"
	$(eval SIZE := $(shell stat -c%s "$(ZIP_PATH)"))
	$(eval CHECKSUM := $(shell sha256sum "$(ZIP_PATH)" | cut -d ' ' -f 1))
	mkdir -p $(BUILD_DIR)
	@echo '{' > $(INDEX_FILE)
	@echo '  "packages": [' >> $(INDEX_FILE)
	@echo '    {' >> $(INDEX_FILE)
	@echo '      "name": "$(PACKAGER)",' >> $(INDEX_FILE)
	@echo '      "platforms": [' >> $(INDEX_FILE)
	@echo '        {' >> $(INDEX_FILE)
	@echo '          "name": "$(CORE_NAME)",' >> $(INDEX_FILE)
	@echo '          "architecture": "$(ARCH)",' >> $(INDEX_FILE)
	@echo '          "version": "$(VERSION)",' >> $(INDEX_FILE)
	@echo '          "category": "Contributed",' >> $(INDEX_FILE)
	@echo '          "url": "$(BASE_URL)",' >> $(INDEX_FILE)
	@echo '          "archiveFileName": "$(ZIP_NAME)",' >> $(INDEX_FILE)
	@echo '          "checksum": "SHA-256:$(CHECKSUM)",' >> $(INDEX_FILE)
	@echo '          "size": $(SIZE),' >> $(INDEX_FILE)
	@echo '          "boards": [' >> $(INDEX_FILE)
	@echo '            {"name": "ATmega328"},' >> $(INDEX_FILE)
	@echo '            {"name": "ATmega168"},' >> $(INDEX_FILE)
	@echo '            {"name": "ATtiny85"},' >> $(INDEX_FILE)
	@echo '            {"name": "ATtiny45"}' >> $(INDEX_FILE)
	@echo '          ],' >> $(INDEX_FILE)
	@echo '          "toolsDependencies": []' >> $(INDEX_FILE)
	@echo '        }' >> $(INDEX_FILE)
	@echo '      ],' >> $(INDEX_FILE)
	@echo '      "tools": []' >> $(INDEX_FILE)
	@echo '    }' >> $(INDEX_FILE)
	@echo '  ]' >> $(INDEX_FILE)
	@echo '}' >> $(INDEX_FILE)
	@echo " Fichier JSON généré : $(INDEX_FILE)"

clean:
	rm -rf $(BUILD_DIR)
