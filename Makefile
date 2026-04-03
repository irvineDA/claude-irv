CLAUDE_DIR := $(HOME)/.claude
DIST_DIR := dist

.PHONY: install uninstall package clean

package:
	@mkdir -p $(DIST_DIR)
	@for skill in skills/*/; do \
		name=$$(basename "$$skill"); \
		echo "  Packaging $$name..."; \
		(cd skills && zip -r ../$(DIST_DIR)/$$name.skill $$name/ -x "*.DS_Store"); \
	done
	@echo "Done. Archives written to $(DIST_DIR)/"

clean:
	@rm -rf $(DIST_DIR)
	@echo "Removed $(DIST_DIR)/"

install:
	@echo "Installing plugin components to $(CLAUDE_DIR)..."
	@if [ -d skills ]; then \
		mkdir -p $(CLAUDE_DIR)/skills; \
		cp -r skills/. $(CLAUDE_DIR)/skills/; \
		echo "  Installed skills/"; \
	fi
	@if [ -d commands ]; then \
		mkdir -p $(CLAUDE_DIR)/commands; \
		cp -r commands/. $(CLAUDE_DIR)/commands/; \
		echo "  Installed commands/"; \
	fi
	@if [ -d agents ]; then \
		mkdir -p $(CLAUDE_DIR)/agents; \
		cp -r agents/. $(CLAUDE_DIR)/agents/; \
		echo "  Installed agents/"; \
	fi
	@if [ -f hooks/hooks.json ]; then \
		mkdir -p $(CLAUDE_DIR)/hooks; \
		cp hooks/hooks.json $(CLAUDE_DIR)/hooks/hooks.json; \
		echo "  Installed hooks/hooks.json"; \
	fi
	@echo "Done."

uninstall:
	@echo "Uninstalling plugin components from $(CLAUDE_DIR)..."
	@if [ -d skills ]; then \
		for skill in skills/*/; do \
			name=$$(basename "$$skill"); \
			rm -rf $(CLAUDE_DIR)/skills/$$name; \
			echo "  Removed skills/$$name"; \
		done; \
	fi
	@if [ -d commands ]; then \
		for cmd in commands/*; do \
			name=$$(basename "$$cmd"); \
			rm -f $(CLAUDE_DIR)/commands/$$name; \
			echo "  Removed commands/$$name"; \
		done; \
	fi
	@if [ -d agents ]; then \
		for agent in agents/*/; do \
			name=$$(basename "$$agent"); \
			rm -rf $(CLAUDE_DIR)/agents/$$name; \
			echo "  Removed agents/$$name"; \
		done; \
	fi
	@if [ -f hooks/hooks.json ]; then \
		rm -f $(CLAUDE_DIR)/hooks/hooks.json; \
		echo "  Removed hooks/hooks.json"; \
	fi
	@if [ -f .mcp.json ]; then \
		rm -f $(CLAUDE_DIR)/.mcp.json; \
		echo "  Removed .mcp.json"; \
	fi
	@echo "Done."