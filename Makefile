# This Makefile requires you to have terraform and prettier installed. 

generate_docs:
	@echo "📝 Generating Terraform documentation..."
	@for dir in ./*/ ; do \
		if [ "$(basename $$dir)" != "examples" ]; then \
			if [ -f "$${dir}README.md" ]; then \
				echo "🔄 Updating documentation for $$dir"; \
				terraform-docs markdown table --output-file "README.md" "$${dir}"; \
				prettier --write "$${dir}README.md"; \
				echo "✅ Documentation updated for $$dir"; \
			fi; \
		fi; \
	done
	@echo "Documentation generation complete ✔️"

format:
	@echo "📝 Formatting Terraform files..."
	terraform fmt --recursive
	@echo "Formatting complete ✔️"