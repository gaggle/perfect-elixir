.PHONY: test

test:
	@for script in test/scenarios/*; do \
		echo "Running $$script..."; \
		set -e; \
		./$$script; \
	done

watch:
	@script=$(script); \
	if [ -z "$$script" ]; then \
		echo "Usage: make watch script=SCRIPT_PATH"; \
	else \
		old_hash=""; \
		while true; do \
			new_hash=$$(find bin test -type f -exec stat -f "%m%N" {} + | sort | md5); \
			if [ "$$new_hash" != "$$old_hash" ]; then \
				echo "Running $$script..."; \
				./$$script; \
				echo "\n\n"; \
				old_hash=$$new_hash; \
			fi; \
			sleep 0.45; \
		done; \
	fi
