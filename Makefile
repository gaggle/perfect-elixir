.PHONY: test

test:
	@for script in test/scenarios/*; do \
		echo "Running $$script..."; \
		set -e; \
		./$$script; \
	done
