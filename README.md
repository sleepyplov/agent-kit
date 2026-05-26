# Agent Kit

Just a collection of project maintenance and vibecoding-related tools and prompt templates, primarily written by LLMs.

## Installation and updates

To install or update the tools, download the `install.sh` script and run it:
```bash
curl -sSL https://raw.githubusercontent.com/sleepyplov/agent-kit/main/install.sh | bash
```

The install script downloads the repository to `$HOME/.local/src/agent-kit` and symlinks executables to `$HOME/.local/bin`.

Override the repo source by setting `AGENT_KIT_REPO_URL` and `AGENT_KIT_BRANCH` environment variables
