#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner astral-sh --repo uv --version "$VERSION" --binary uv,uvx
}

main "$@"
