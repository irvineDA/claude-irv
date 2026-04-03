CLAUDE_DIR := $(HOME)/.claude
SRC_DIR := .claude
DIST_DIR := dist

.PHONY: install uninstall package clean

package:
	@mkdir -p $(DIST_DIR)
	@for skill in $(SRC_DIR)/skills/*/; do \
		name=$$(basename "$$skill"); \
		echo "  Packaging $$name..."; \
		(cd $(SRC_DIR)/skills && zip -r ../../$(DIST_DIR)/$$name.skill $$name/ -x "*.DS_Store"); \
	done
	@echo "Done. Archives written to $(DIST_DIR)/"

clean:
	@rm -rf $(DIST_DIR)
	@echo "Removed $(DIST_DIR)/"

install:
	@echo "Installing plugin components to $(CLAUDE_DIR)..."
	@if [ -d $(SRC_DIR)/skills ]; then \
		mkdir -p $(CLAUDE_DIR)/skills; \
		cp -r $(SRC_DIR)/skills/. $(CLAUDE_DIR)/skills/; \
		echo "  Installed skills/"; \
	fi
	@if [ -d $(SRC_DIR)/commands ]; then \
		mkdir -p $(CLAUDE_DIR)/commands; \
		cp -r $(SRC_DIR)/commands/. $(CLAUDE_DIR)/commands/; \
		echo "  Installed commands/"; \
	fi
	@if [ -d $(SRC_DIR)/agents ]; then \
		mkdir -p $(CLAUDE_DIR)/agents; \
		cp -r $(SRC_DIR)/agents/. $(CLAUDE_DIR)/agents/; \
		echo "  Installed agents/"; \
	fi
	@if [ -f $(SRC_DIR)/hooks/hooks.json ]; then \
		mkdir -p $(CLAUDE_DIR)/hooks; \
		cp $(SRC_DIR)/hooks/hooks.json $(CLAUDE_DIR)/hooks/hooks.json; \
		echo "  Installed hooks/hooks.json"; \
	fi
	@echo "Done."

uninstall:
	@echo "Uninstalling plugin components from $(CLAUDE_DIR)..."
	@if [ -d $(SRC_DIR)/skills ]; then \
		for skill in $(SRC_DIR)/skills/*/; do \
			name=$$(basename "$$skill"); \
			rm -rf $(CLAUDE_DIR)/skills/$$name; \
			echo "  Removed skills/$$name"; \
		done; \
	fi
	@if [ -d $(SRC_DIR)/commands ]; then \
		for cmd in $(SRC_DIR)/commands/*; do \
			name=$$(basename "$$cmd"); \
			rm -f $(CLAUDE_DIR)/commands/$$name; \
			echo "  Removed commands/$$name"; \
		done; \
	fi
	@if [ -d $(SRC_DIR)/agents ]; then \
		for agent in $(SRC_DIR)/agents/*/; do \
			name=$$(basename "$$agent"); \
			rm -rf $(CLAUDE_DIR)/agents/$$name; \
			echo "  Removed agents/$$name"; \
		done; \
	fi
	@if [ -f $(SRC_DIR)/hooks/hooks.json ]; then \
		rm -f $(CLAUDE_DIR)/hooks/hooks.json; \
		echo "  Removed hooks/hooks.json"; \
	fi
	@if [ -f .mcp.json ]; then \
		rm -f $(CLAUDE_DIR)/.mcp.json; \
		echo "  Removed .mcp.json"; \
	fi
	@echo "Done."