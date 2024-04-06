import os
import subprocess
import sys

try:
    import pexpect
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pexpect"])
    import pexpect

BIN_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../bin"))
DEBUG = bool(os.getenv("VERBOSE") or (os.getenv("GITHUB_ACTIONS") and os.getenv("RUNNER_DEBUG")))
PREFIX = "OUTPUT >>"
PROMPT = "PROMPT $ "


def init_zsh():
    child = pexpect.spawn("zsh -f", env={"PS1": PROMPT}, timeout=5, echo=DEBUG)
    if DEBUG: child.logfile = sys.stdout.buffer
    child.expect_exact(PROMPT)

    child.sendline(f'alias p=\'printf "{PREFIX} "\'')
    child.expect_exact(PROMPT)

    child.sendline("p")
    child.expect_exact(PREFIX)
    child.sendline('p; echo "$ZSH_VERSION"')
    child.expect_exact(PREFIX)

    if not DEBUG: child.logfile_read = sys.stdout.buffer
    return child


def init_bash():
    child = pexpect.spawn("bash --noprofile --norc",
                          env={"PS1": PROMPT, "PATH": os.getenv("PATH")},
                          timeout=5, echo=DEBUG)
    if DEBUG: child.logfile = sys.stdout.buffer
    child.expect_exact(PROMPT)

    child.sendline(f'alias p=\'printf "{PREFIX} "\'')
    child.expect_exact(PROMPT)

    child.sendline("p")
    child.expect_exact(PREFIX)
    child.sendline('p; echo "$BASH_VERSION"')
    child.expect_exact(PREFIX)

    if not DEBUG: child.logfile_read = sys.stdout.buffer
    return child


def teardown_zsh(child):
    child.sendline("exit")
    child.expect(pexpect.EOF)
    child.close()


def teardown_bash(child):
    child.sendline("exit")
    child.expect(pexpect.EOF)
    child.close()


def run_tests_against_shells(scenario, **kwargs):
    if kwargs.get("zsh", True):
        print("ℹ️ TESTING ZSH…")
        zsh_child = init_zsh()
        try:
            scenario(zsh_child, PREFIX, BIN_DIR, PROMPT)
        except (pexpect.exceptions.TIMEOUT, pexpect.exceptions.EOF) as e:
            zsh_child.close(force=True)
            print(str(e))
            sys.exit(zsh_child.exitstatus)
        teardown_zsh(zsh_child)
        if zsh_child.exitstatus:
            raise Exception(f"Zsh test failed with exit status {zsh_child.exitstatus}")
        print("ℹ️ Zsh exit status:", zsh_child.exitstatus)

    if kwargs.get("bash", True):
        print("\nℹ️ TESTING BASH…")
        bash_child = init_bash()
        try:
            scenario(bash_child, PREFIX, BIN_DIR, PROMPT)
        except (pexpect.exceptions.TIMEOUT, pexpect.exceptions.EOF) as e:
            bash_child.close(force=True)
            print(str(e))
            sys.exit(bash_child.exitstatus)
        teardown_bash(bash_child)
        if bash_child.exitstatus:
            raise Exception(f"Bash test failed with exit status {bash_child.exitstatus}")
        print("ℹ️ Bash exit status:", bash_child.exitstatus)
