#!/bin/bash

set -eo pipefail

: "${LOG_LEVEL:=INFO}"   # DEBUG|INFO|WARN|ERROR

WORKSPACE_DIR="$(pwd)"
WELCOME_SRC=".devcontainer/welcome.txt"
WELCOME_DST_DIR="/usr/local/etc/vscode-dev-containers"
WELCOME_DST="${WELCOME_DST_DIR}/first-run-notice.txt"
CMD_HISTORY_DIR="/cmd_history"

_lvl_to_num() {
  case "${1:-INFO}" in
    DEBUG) echo 10 ;;
    INFO)  echo 20 ;;
    WARN)  echo 30 ;;
    ERROR) echo 40 ;;
    *)     echo 20 ;;
  esac
}

_should_log() {
  local lvl="$1"
  [ "$(_lvl_to_num "$lvl")" -ge "$(_lvl_to_num "$LOG_LEVEL")" ]
}

log() { _should_log "$1" && printf "[%s] %s\n" "$1" "$2" >&2 || true; }

log_debug() { log DEBUG "$1"; }
log_info()  { log INFO  "$1"; }
log_warn()  { log WARN  "$1"; }
log_error() { log ERROR "$1"; }

on_error() {
  log_error "Script failed on line ${BASH_LINENO[0]} (cmd: ${BASH_COMMAND})"
}

trap on_error ERR

APT_UPDATED=0

apt_update_once() {
  if [ "$APT_UPDATED" -eq 0 ]; then
    log_info "Updating apt package lists..."
    sudo apt-get update -y
    APT_UPDATED=1
  else
    log_debug "apt-get update already run; skipping."
  fi
}

apt_install() {
  local pkgs=("$@")
  apt_update_once
  log_info "Installing packages: ${pkgs[*]}"
  sudo apt-get install -y "${pkgs[@]}"
}

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

curl_json_field() {
  local url="$1" key="$2"
  curl -fsSL "$url" | grep -Po "\"${key}\": *\"\\K[^\"]*"
}

copy_welcome_notice() {
  if [ -f "$WELCOME_SRC" ]; then
    log_info "Installing welcome notice to ${WELCOME_DST}"
    sudo mkdir -p "$WELCOME_DST_DIR"
    sudo cp "$WELCOME_SRC" "$WELCOME_DST"
  else
    log_warn "Welcome notice not found at ${WELCOME_SRC}; skipping."
  fi
}

fix_cmd_history_permissions() {
  log_info "Ensuring ${CMD_HISTORY_DIR} exists and owned by vscode:vscode..."
  sudo mkdir -p "$CMD_HISTORY_DIR"
  sudo chown -R vscode:vscode "$CMD_HISTORY_DIR"
}

verify_git_available() {
  if cmd_exists git; then
    log_info "Git found: $(git --version)"
  else
    log_error "Git not found on PATH. The dev container is expected to provide Git."
    return 1
  fi
}

ensure_npm() {
  if cmd_exists npm; then
    log_info "npm found: $(npm --version)"
  else
    log_warn "npm not found; installing via apt..."
    apt_install npm
    log_info "npm installed: $(npm --version)"
  fi
}

install_biome() {
  if cmd_exists biome; then
    log_info "Biome found: $(biome --version || echo 'biome version check failed')"
    return 0
  fi

  ensure_npm

  log_info "Installing @biomejs/biome globally..."
  sudo npm install -g @biomejs/biome
  log_info "Biome installed: $(biome --version || echo 'biome version check failed')"
}

setup_pre_commit() {
  if ! cmd_exists pre-commit; then
    log_warn "pre-commit not found; attempting install."

    if cmd_exists pipx; then
      log_info "Installing pre-commit via pipx..."
      sudo pipx install pre-commit
    else
      log_warn "pipx/pip3 unavailable; skipping pre-commit installation."
    fi
  fi

  if cmd_exists pre-commit; then
    log_info "Installing pre-commit hooks..."
    pre-commit install --install-hooks
    log_info "Running pre-commit on all files..."
    pre-commit run --all-files
  else
    log_warn "pre-commit still not available; skipping hook install and run."
  fi
}

install_lazygit() {
  local api="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
  local latest ver arch raw_arch tarball tmp
  if cmd_exists lazygit; then
    ver="$(lazygit --version 2>/dev/null | awk '{print $3}' | head -n1 || true)"
    log_info "lazygit found (installed version: ${ver:-unknown})"
  else
    log_info "lazygit not found; will install latest."
  fi

  latest="$(curl_json_field "$api" "tag_name" | sed 's/^v//')"
  if [ -z "${latest:-}" ]; then
    log_warn "Failed to fetch latest lazygit version; skipping install."
    return 0
  fi

  if cmd_exists lazygit && [ "${ver:-}" = "$latest" ]; then
    log_info "lazygit is up-to-date (v$latest); skipping install."
    return 0
  fi

  raw_arch="$(uname -m)"
  case "$raw_arch" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) arch="x86_64"; log_warn "Unsupported arch '$raw_arch'; defaulting to x86_64." ;;
  esac

  tarball="lazygit_${latest}_Linux_${arch}.tar.gz"
  tmp="$(mktemp -d)"
  log_info "Downloading lazygit v${latest} for Linux ${arch}..."
  if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${latest}/${tarball}" -o "${tmp}/lazygit.tgz"; then
    tar -xzf "${tmp}/lazygit.tgz" -C "$tmp" lazygit
    log_info "Installing lazygit to /usr/local/bin..."
    sudo install -m 0755 "${tmp}/lazygit" /usr/local/bin/lazygit
    rm -rf "$tmp"
    log_info "lazygit installed: $(lazygit --version || echo 'version check failed')"
  else
    rm -rf "$tmp"
    log_warn "Failed to download lazygit tarball; skipping install."
  fi
}

install_go_task() {
  if cmd_exists task; then
    log_info "Go Task found: $(task --version 2>/dev/null | head -n1 || echo 'version check failed')"
    return 0
  fi
  log_info "Installing Go Task..."
  curl -fsSL https://taskfile.dev/install.sh | sudo sh -s -- -d -b /usr/local/bin
  log_info "Go Task installed: $(task --version 2>/dev/null | head -n1 || echo 'version check failed')"
}

main() {
  log_info "Starting post-create setup in ${WORKSPACE_DIR}"

  copy_welcome_notice
  fix_cmd_history_permissions
  verify_git_available

  install_biome
  setup_pre_commit

  install_lazygit
  install_go_task

  log_info "Post-create setup complete."
}

main "$@"
