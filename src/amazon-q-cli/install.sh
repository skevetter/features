#!/bin/bash
set -e

check_prerequisites() {
    command -v q >/dev/null 2>&1 && {
        echo "Amazon Q CLI already installed"
        exit 0
    }
    [[ "$(uname -s)" == "Linux" ]] || {
        echo "ERROR: Amazon Q CLI only supports Linux"
        exit 1
    }
}

install_dependencies() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y curl unzip
}

get_architecture() {
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64) echo "x86_64" ;;
        aarch64) echo "aarch64" ;;
        *)
            echo "ERROR: Unsupported architecture: $arch" >&2
            exit 1
            ;;
    esac
}

get_musl_suffix() {
    local version major minor
    version=$(ldd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "0.0")
    major=${version%%.*}
    minor=${version##*.}

    [[ $major -gt 2 || ($major -eq 2 && $minor -ge 34) ]] && echo "" || echo "-musl"
}

download_and_install() {
    local arch_name=$1
    local suffix=$2
    local temp_dir
    temp_dir=$(mktemp -d)

    cd "$temp_dir"
    echo "Downloading Amazon Q CLI"
    curl -sSfL "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-${arch_name}-linux${suffix}.zip" -o q.zip

    echo "Installing Amazon Q CLI"
    unzip -q q.zip

    # Extract binaries manually since installer doesn't support root
    mkdir -p /usr/local/bin
    cp q/bin/* /usr/local/bin/
    chmod +x /usr/local/bin/q /usr/local/bin/qchat /usr/local/bin/qterm

    cd /
    rm -rf "$temp_dir"
}

verify_installation() {
    if command -v q >/dev/null 2>&1; then
        echo "Amazon Q CLI installed successfully"
        q --version
    else
        echo "ERROR: Installation failed"
        exit 1
    fi
}

setup_completion_and_integrations() {
    mkdir -p /etc/bash_completion.d
    q completion bash >/etc/bash_completion.d/q

    mkdir -p /etc/profile.d
    cat >/etc/profile.d/amazon-q.sh <<'EOF'
export Q_TERM=1
if [ -f /etc/bash_completion.d/q ]; then
    source /etc/bash_completion.d/q
fi
EOF

    q integrations install dotfiles
}

main() {
    echo "Activating feature 'amazon-q-cli'"

    check_prerequisites
    install_dependencies

    local arch_name suffix
    arch_name=$(get_architecture)
    suffix=$(get_musl_suffix)

    download_and_install "$arch_name" "$suffix"
    verify_installation
    setup_completion_and_integrations

    echo "Amazon Q CLI installation complete!"
}

main "$@"
