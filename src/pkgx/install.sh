#!/usr/bin/env bash

set -eo pipefail

main() {
    picolayer gh-release --owner pkgxdev --repo pkgx --version "$VERSION" --verify-checksum --gpg-key https://dist.pkgx.dev/gpg-public.asc
}

main "$@"
