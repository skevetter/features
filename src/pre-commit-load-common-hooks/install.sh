#!/usr/bin/env bash

set -eo pipefail

. ./lib.sh

USER="${FEATURE_USER:-${_REMOTE_USER:-"vscode"}}"
PRE_COMMIT_HOME="/pre_commit_cache"
PRE_COMMIT_DEFAULT_BIN="/usr/local/py-utils/bin/pre-commit"
NANOLAYER_VERSION="v0.5.6"

run_as_user() { sudo -u "$USER" "$@"; }

pre_commit_config_install() {
    config=$1
    echo "Installing pre-commit ${config} hooks"

    nanolayer_command="set -ex
export PRE_COMMIT_HOME=$PRE_COMMIT_HOME

GIT_DIR=$(mktemp -d)
cd $GIT_DIR
git init --quiet
git config --global init.defaultBranch main
git config --global user.email \"dev@container\"
git config --global user.name \"devcontainer\"
git config --global safe.directory \"*\"
touch README.md
git add README.md
git commit -m \"Initial commit\"

cat > .pre-commit-config.yaml <<'EOF'
$(cat "config/${config}.yaml")
EOF

$PRE_COMMIT_BIN install --install-hooks -c .pre-commit-config.yaml
rm -rf .git

echo Nanolayer command completed"

    # shellcheck disable=SC2154
    "${nanolayer_location}" \
        install \
        devcontainer-feature \
        "ghcr.io/devcontainers-extra/features/bash-command:1" \
        --option command="$(run_as_user) $nanolayer_command"
}

main() {
    echo "Ensuring nanolayer CLI (${NANOLAYER_VERSION}) is available"
    ensure_nanolayer nanolayer_location "${NANOLAYER_VERSION}"

    if [ -z "${PRE_COMMIT_BIN}" ] ; then
        if type pre-commit >/dev/null 2>&1; then
            PRE_COMMIT_BIN=pre-commit
        elif [ -x "$PRE_COMMIT_DEFAULT_BIN" ] ; then
            PRE_COMMIT_BIN=$PRE_COMMIT_DEFAULT_BIN
        else
            echo "pre-commit is not installed or not found in PATH"
            exit 1
        fi
    fi

    pre_commit_config_install base
    pre_commit_config_install python
    pre_commit_config_install shell
    pre_commit_config_install lua

    if command -v rustc >/dev/null 2>&1; then
        pre_commit_config_install rust
    else
        echo "Skipping Rust hook installation."
    fi

    if command -v go >/dev/null 2>&1; then
        pre_commit_config_install golang
    else
        echo "Skipping Go hook installation."
    fi

    if command -v terraform >/dev/null 2>&1; then
        pre_commit_config_install terraform
    else
        echo "Skipping Terraform hook installation."
    fi

    echo "Done!"
}

main "$@"
