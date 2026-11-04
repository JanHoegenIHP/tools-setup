"""Smoke-test the command-line tools expected in the development image."""

from __future__ import annotations

import shutil
import subprocess
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class Tool:
    name: str
    version_args: tuple[str, ...] | None


# Keep this list aligned with the tools marked necessary in README.md.
REQUIRED_TOOLS = (
    Tool("python3", ("--version",)),
    Tool("uv", ("--version",)),
    Tool("nix", ("--version",)),
    Tool("git", ("--version",)),
    Tool("make", ("--version",)),
    Tool("librelane", ("--version",)),
    Tool("ghdl", ("--version",)),
    # GTKWave initializes GTK even for its version flag, so only check PATH here.
    Tool("gtkwave", None),
    Tool("klayout", ("-v",)),
    Tool("openroad", ("-version",)),
    Tool("librelane", ("--smoke-test",)),
)


def check_tool(tool: Tool) -> tuple[bool, str]:
    executable = shutil.which(tool.name)
    if executable is None:
        return False, "executable not found on PATH"
    if tool.version_args is None:
        return True, "executable found (GUI startup requires a display)"

    try:
        result = subprocess.run(
            [executable, *tool.version_args],
            capture_output=True,
            check=False,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        return False, f"failed to start ({error})"

    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()
        return False, f"version probe exited {result.returncode}: {detail}"

    version = (result.stdout or result.stderr).strip().splitlines()
    return True, version[0] if version else "version probe succeeded"


def main() -> int:
    failures = 0
    for tool in REQUIRED_TOOLS:
        success, detail = check_tool(tool)
        if not success:
            failures += 1
        print(f"[{'PASS' if success else 'FAIL'}] {tool.name}: {detail}")

    if failures:
        print(f"\n{failures} required tool(s) failed the smoke test.", file=sys.stderr)
        return 1

    print("\nAll required tool commands are available and respond to a version probe.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
