is_apt_system() { [ -x "/usr/bin/apt-get" ]; }
is_apk_system() { [ -x "/sbin/apk" ]; }
is_supported_platform() {
    local os
    os=$(uname -s)
    local arch
    arch=$(uname -m)
    { [ "$os" = "Linux" ] || [ "$os" = "Darwin" ]; } && { [ "$arch" = "x86_64" ] || [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; }
}

has_curl() { type curl >/dev/null 2>&1; }
has_wget() { type wget >/dev/null 2>&1; }
get_downloader() {
    if has_curl; then
        echo "curl"
    elif has_wget; then
        echo "wget"
    else
        echo ""
    fi
}

backup_apt_state() { cp -pR /var/lib/apt/lists "$1"; }
restore_apt_state() {
    rm -rf /var/lib/apt/lists/*
    mv "$1"/lists /var/lib/apt/lists
}
install_wget_apt() { apt-get update -y && apt-get -y install --no-install-recommends wget ca-certificates; }
remove_wget_apt() { apt-get -y purge wget --auto-remove; }

backup_apk_state() { cp -pR /var/cache/apk "$1"; }
install_wget_apk() { apk add --no-cache wget; }
remove_wget_apk() { apk del wget; }

download_file() {
    local url="$1" output="$2" downloader
    downloader=$(get_downloader)

    if [ -z "$downloader" ]; then
        local tempdir
        tempdir=$(mktemp -d)
        if is_apt_system; then
            backup_apt_state "$tempdir"
            install_wget_apt
            wget --no-check-certificate -O "$output" "$url" || return 1
            remove_wget_apt
            restore_apt_state "$tempdir"
        elif is_apk_system; then
            backup_apk_state "$tempdir"
            install_wget_apk
            wget --no-check-certificate -O "$output" "$url" || return 1
            remove_wget_apk
        else
            echo "Unsupported system" >&2
            return 1
        fi
        rm -rf "$tempdir"
    elif [ "$downloader" = "curl" ]; then
        curl -fsSL "$url" -o "$output" || return 1
    elif [ "$downloader" = "wget" ]; then
        wget --no-check-certificate -O "$output" "$url" || return 1
    else
        echo "Unknown downloader: $downloader" >&2
        return 1
    fi
}

ensure_cli_tool() {
    local tool_name="$1" version="$2" url="$3"
    local location=""

    if [ -z "${PICOLAYER_FORCE_CLI_INSTALLATION}" ]; then
        local env_var="${tool_name^^}_CLI_LOCATION"
        local env_location
        env_location=$(eval echo "\$${env_var}")

        if [ -z "$env_location" ] && type "$tool_name" >/dev/null 2>&1; then
            echo "Found pre-existing $tool_name in PATH"
            location="$tool_name"
        elif [ -f "$env_location" ] && [ -x "$env_location" ]; then
            echo "Found pre-existing $tool_name at: $env_location"
            location="$env_location"
        fi

        if [ -n "$location" ]; then
            local current_version
            current_version=$($location --version 2>/dev/null || echo "")
            if [ "$current_version" != "$version" ]; then
                echo "Version mismatch for $tool_name (required: $version, found: $current_version)"
                location=""
            fi
        fi
    fi

    if [ -z "$location" ]; then
        if ! is_supported_platform; then
            echo "No binaries for $(uname -sm)" >&2
            return 1
        fi

        local tmp_dir
        tmp_dir=$(mktemp -d -t "$tool_name-XXXXXXXXXX")
        trap 'rm -rf $tmp_dir' EXIT

        local archive
        archive="$tmp_dir/$(basename "$url")"
        download_file "$url" "$archive"
        tar xfz "$archive" -C "$tmp_dir"
        chmod +x "$tmp_dir/$tool_name"
        location="$tmp_dir/$tool_name"
    fi

    export PICOLAYER_BIN="$location"
}

ensure_picolayer() {
    local version="${1:-latest}"
    local os
    os=$(uname -s)
    local arch
    arch=$(uname -m)

    case "$os" in
    Linux) os="unknown-linux-gnu" ;;
    Darwin) os="apple-darwin" ;;
    *)
        echo "Unsupported OS: $os" >&2
        return 1
        ;;
    esac

    case "$arch" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="aarch64" ;;
    *)
        echo "Unsupported architecture: $arch" >&2
        return 1
        ;;
    esac

    local url="https://github.com/skevetter/picolayer/releases/$version/download/picolayer-$arch-$os.tar.gz"
    ensure_cli_tool "picolayer" "$version" "$url"
}
