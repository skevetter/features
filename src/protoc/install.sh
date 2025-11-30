#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer apt-get protobuf-compiler
}

main "$@"
