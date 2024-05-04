.PHONY: test list-tests watch clean

test:
	TEST_SHELL=zsh bats --print-output-on-failure test
	TEST_SHELL=bash bats --print-output-on-failure test

list-tests:
	@find test -name '*.bats' -print0 | xargs -0 grep -H '^@test "' | sed 's/\(.*\.bats\):@test "\(.*\)" {.*/\1#\2/' | sort

watch:
	@echo "Watching for changes… (Press Ctrl-C to stop)"
	@old_hash=""
	@while true; do \
		new_hash=$$(find bin test -type f -exec stat --format='%Y %n' {} + | sort | md5sum); \
		if [ "$$new_hash" != "$$old_hash" ]; then \
			echo "Detected changes, re-running…"; \
			target=$${FILE:-test}; \
			options=""; \
			if [ -n "$(TEST)" ]; then \
				options="-f '$(TEST)'"; \
			fi; \
			if [ -z "$(TEST_SHELL)" ]; then \
				echo "Running all shells: bats $$target $$options"; \
				echo "Running 'zsh'"; \
				eval "TEST_SHELL=zsh bats --print-output-on-failure $$target $$options"; \
				echo "Running 'bash'"; \
				eval "TEST_SHELL=bash bats --print-output-on-failure $$target $$options"; \
			else \
				echo "Running '$$TEST_SHELL': bats $$target $$options"; \
				eval "bats --print-output-on-failure $$target $$options"; \
			fi; \
			echo "Waiting for more changes…\n"; \
			old_hash=$$new_hash; \
		fi; \
		sleep 0.45; \
	done;

clean:
	bin/db nuke
	rm -rf deps
	rm -rf _build
	git clean -ndx --exclude=.idea/
	echo "$$ git clean -dx --exclude=.idea/"

deploy_bootstrap:
	git worktree add ../.temp-deploy-bootstrap main
	cp bin/bootstrap ../.temp-deploy-bootstrap/bootstrap
	cd ../.temp-deploy-bootstrap && git add bootstrap
	cd ../.temp-deploy-bootstrap && git diff --staged --exit-code || git commit -m "Deploy bootstrap script to main branch"
	cd ../.temp-deploy-bootstrap && git push origin main
	git worktree remove ../.temp-deploy-bootstrap
