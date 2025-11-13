.PHONY: install uninstall check help

help:
	@echo "Cronity - Installation Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make install     - Install Cron Manager to system"
	@echo "  make uninstall   - Remove Cron Manager from system"
	@echo "  make check       - Check installation status"
	@echo "  make help        - Show this help message"
	@echo ""

install:
	chmod +x ./install.sh
	./install.sh
	cp ./icon.png /usr/share/icons/hicolor/scalable/apps/cronity.png
	cp ./cronity.desktop /usr/share/applications/cronity.desktop
	cp ./cronity.sh /usr/bin/cronity
	chmod a+rx /usr/bin/cronity
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "✓ Installation complete!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Run 'cronity' from terminal"
	@echo "or find it in your applications menu"
	@echo ""

uninstall:
	rm -f /usr/share/applications/cronity.desktop
	rm -f /usr/bin/cronity
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "✓ Uninstallation complete!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Note: Backup files in ~/.config/cronity/"
	@echo "      are not removed"
	@echo ""

check:
	@echo "Checking Cron Manager installation..."
	@echo ""
	@echo "Installation Status:"
	@echo "━━━━━━━━━━━━━━━━━━━━"
	@if [ -f /usr/bin/cronity ]; then \
		echo "✓ Script: Installed at /usr/bin/cronity"; \
	else \
		echo "✗ Script: Not installed"; \
	fi
	@echo ""
	@if [ -f /usr/share/applications/cronity.desktop ]; then \
		echo "✓ Desktop entry: Installed"; \
	else \
		echo "✗ Desktop entry: Not installed"; \
	fi
	@echo ""
	@echo "Dependencies:"
	@echo "━━━━━━━━━━━━━"
	@which zenity > /dev/null 2>&1 && echo "✓ zenity: Found" || echo "✗ zenity: Not found"
	@which crontab > /dev/null 2>&1 && echo "✓ crontab: Found" || echo "✗ crontab: Not found"
	@echo ""
