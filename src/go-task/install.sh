#!/usr/bin/env bash

set -eo pipefail

main() {
    case "$(uname -s)" in
        Linux)
            os="linux"
            ;;
        Darwin)
            os="darwin"
            ;;
        *)
            echo "Unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64 | amd64)
            arch="amd64"
            ;;
        aarch64 | arm64)
            arch="arm64"
            ;;
        *)
            arch="$(uname -m)"
            ;;
    esac

    asset_regex="task_${os}_${arch}\\.tar\\.gz$"

    echo "Detected OS=${os} ARCH=${arch} -> Filter=${asset_regex}"

    picolayer gh-release --owner go-task --repo task --binary task --filter "${asset_regex}" --version "$VERSION"
}

main "$@"
