.PHONY: test watch clean

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
			new_hash=$$(find bin test -type f -exec stat --format='%Y %n' {} + | sort | md5); \
			if [ "$$new_hash" != "$$old_hash" ]; then \
				echo "Running $$script..."; \
				./$$script; \
				echo "\n\n"; \
				old_hash=$$new_hash; \
			fi; \
			sleep 0.45; \
		done; \
	fi

clean:
	bin/db nuke
	rm -rf deps
	rm -rf _build
	git clean -ndx --exclude=.idea/
	echo "$$ git clean -dx --exclude=.idea/"

deploy_bootstrap:
	git worktree add ../.temp-deploy-bootstrap main
	cp bin/bootstrap ../.temp-deploy-bootstrap
	cd ../.temp-deploy-bootstrap && git add bootstrap && git commit -m "Deploy bootstrap script to main branch"
	git push origin main
	git worktree remove ../.temp-deploy-bootstrap
