# Homebrew Tap for oak-ci

Homebrew formulae for [Open Agent Kit (OAK)](https://github.com/goondocks-co/open-agent-kit) — codebase intelligence toolkit for development workflows.

## Install

```bash
brew install goondocks-co/oak/oak-ci
```

Or add the tap first:

```bash
brew tap goondocks-co/oak
brew install oak-ci
```

## Upgrade

```bash
brew upgrade oak-ci
```

## Uninstall

```bash
brew uninstall oak-ci
```

## Getting Started

After installing, initialize OAK in your project:

```bash
cd /path/to/your/project
oak init
oak ci start --open
```

## About

This tap is automatically updated on each [oak-ci release](https://github.com/goondocks-co/open-agent-kit/releases). The formula creates a Python 3.13 virtualenv and installs oak-ci from PyPI using pre-built wheels.

## Troubleshooting

If you encounter issues:

```bash
# Reinstall from scratch
brew reinstall oak-ci

# Check what's installed
brew info oak-ci

# View install logs
brew log oak-ci
```

## Links

- [OAK Documentation](https://oak.goondocks.co/)
- [PyPI Package](https://pypi.org/project/oak-ci/)
- [Source Code](https://github.com/goondocks-co/open-agent-kit)
