#!/usr/bin/env bash
set -euo pipefail

# Guard against multiple sourcing
if [ "${__DEVX_LIB_SH__:-}" = "1" ]; then
    return 0 2>/dev/null
fi
__DEVX_LIB_SH__=1

: "${NANOLAYER_VERSION:=v0.5.6}"
: "${DEVX_LOG_LEVEL:=info}" # debug | info | warn | error


#######################################
# Public Functions
#######################################
ensure_nanolayer() {
    local variable_name="${1:?output variable name is required}"
    local required_version="${2:?required version is required}"

    local _nanolayer_location=""
    _nanolayer_location="$(devx_nl__find_preexisting "${required_version}")" || _nanolayer_location=""

    if [ -z "${_nanolayer_location}" ]; then
        _nanolayer_location="$(devx_nl__download_and_unpack "${required_version}")" || return 1
        export NANOLAYER_CLI_LOCATION="${_nanolayer_location}"
    fi

    devx__setvar "${variable_name}" "${_nanolayer_location}"
}


#######################################
# Core helpers
#######################################
devx__setvar() {
    local var="${1:?var required}"
    local val="${2:-}"
    printf -v "$var" '%s' "$val"
}

devx__has() {
    command -v "$1" >/dev/null 2>&1
}

devx__normalize_version() {
    printf "%s" "${1#v}"
}

#######################################
# Logging
#######################################
devx_log__lvl() {
    case "${DEVX_LOG_LEVEL}" in
        debug) echo 0 ;;
        info)  echo 1 ;;
        warn)  echo 2 ;;
        error) echo 3 ;;
        *)     echo 1 ;;
    esac
}

devx_log__should() { # $1=level
    local want have
    case "$1" in
        debug) want=0 ;;
        info)  want=1 ;;
        warn)  want=2 ;;
        error) want=3 ;;
        *)     want=1 ;;
    esac
    have="$(devx_log__lvl)"
    [ "$have" -le "$want" ]
}

devx_log__debug() { devx_log__should debug && echo "[DEBUG] $*" >&2; }
devx_log__info()  { devx_log__should info  && echo "[INFO]  $*" >&2; }
devx_log__warn()  { devx_log__should warn  && echo "[WARN]  $*" >&2; }
devx_log__error() { devx_log__should error && echo "[ERROR] $*" >&2; }

#######################################
# Downloader
#######################################
devx_dl__have_downloader() {
    if devx__has curl; then
        echo "curl"
    elif devx__has wget; then
        echo "wget"
    else
        echo ""
    fi
}

devx_dl__apt_install() { apt-get update && apt-get install -y wget; }
devx_dl__apt_cleanup() { apt-get remove -y wget; }
devx_dl__apk_install() { apk add --no-cache wget; }
devx_dl__apk_cleanup() { apk del wget; }

devx_dl__ensure() {
    local out_name_var="${1:?out var required}"
    local out_flag_var="${2:?out flag var required}"
    local tempdir="${3:?tempdir required}"

    local downloader="" installed=0
    downloader="$(devx_dl__have_downloader)"

    if [ -z "${downloader}" ]; then
        if [ -x "/usr/bin/apt-get" ]; then
            devx_dl__apt_install "${tempdir}"
            downloader="wget"; installed=1
        elif [ -x "/sbin/apk" ]; then
            devx_dl__apk_install "${tempdir}"
            downloader="wget"; installed=1
        else
            devx_log__error "Distro not supported for temporary downloader installation"
            return 1
        fi
    fi

    devx__setvar "${out_name_var}" "${downloader}"
    devx__setvar "${out_flag_var}" "${installed}"
}

devx_dl__perform() {
    local downloader="${1:?downloader required}"
    local url="${2:?url required}"
    local output_location="${3:?output required}"
    if [ "${downloader}" = "wget" ]; then
        wget --quiet --tries=3 --timeout=30 -O "${output_location}" "${url}"
    else
        curl --fail --silent --show-error --location --retry 3 --retry-delay 2 \
             --connect-timeout 30 -o "${output_location}" "${url}"
    fi
}

devx_dl__cleanup() {
    local installed_flag="${1:?installed flag required}"
    local tempdir="${2:?tempdir required}"
    if [ "${installed_flag}" -eq 1 ] 2>/dev/null; then
        if [ -x "/usr/bin/apt-get" ]; then
            devx_dl__apt_cleanup "${tempdir}"
        elif [ -x "/sbin/apk" ]; then
            devx_dl__apk_cleanup "${tempdir}"
        fi
    fi
}

devx_dl__clean_download() {
    local url="${1:?url is required}"
    local output_location="${2:?output location is required}"
    local tempdir; tempdir="$(mktemp -d)"
    local downloader="" downloader_installed=0

    if ! devx_dl__ensure downloader downloader_installed "${tempdir}"; then
        rm -rf "${tempdir}" 2>/dev/null || true
        return 1
    fi

    local dl_rc=0
    devx_dl__perform "${downloader}" "${url}" "${output_location}" || dl_rc=$?
    devx_dl__cleanup "${downloader_installed}" "${tempdir}"
    rm -rf "${tempdir}" 2>/dev/null || true
    return "${dl_rc}"
}

#######################################
# Detect System
#######################################
devx_sys__arch_suffix() {
    case "$(uname -m)" in
        x86_64|amd64) printf "x64" ;;
        aarch64|arm64) printf "arm64" ;;
        *) devx_log__error "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac
}

devx_sys__is_alpine() { [ -x "/sbin/apk" ]; }

devx_sys__libc() {
    if devx_sys__is_alpine || (command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl); then
        printf "musl"
    else
        printf "gnu"
    fi
}

devx_sys__make_asset_regex() {
    local name_prefix="${1:?}"
    local os="${2:?}"
    local arch="${3:?}"
    local ext_regex="${4:?}"
    printf "^%s-.*-%s-%s\\.%s$" "${name_prefix}" "${os}" "${arch}" "${ext_regex}"
}

#######################################
# Nanolayer
#######################################
devx_nl__extract_version_norm() {
    local raw="$1"
    local ver
    ver="$(printf "%s" "${raw}" | grep -Eo 'v?[0-9]+(\.[0-9]+)*' | head -n1 || true)"
    devx__normalize_version "${ver}"
}

devx_nl__arch_for_release() {
    case "$(uname -m)" in
        x86_64|amd64) printf "x86_64" ;;
        aarch64|arm64) printf "aarch64" ;;
        *) devx_log__error "No nanolayer binaries for architecture: $(uname -m)"; return 1 ;;
    esac
}

devx_nl__tar_filename() {
    local arch clib
    arch="$(devx_nl__arch_for_release)" || return 1
    clib="$(devx_sys__libc)"
    printf "nanolayer-%s-unknown-linux-%s.tgz" "${arch}" "${clib}"
}

devx_nl__find_preexisting() {
    local required_version="${1:?required version is required}"
    # shellcheck disable=SC2155
    local want_norm="$(devx__normalize_version "${required_version}")"

    if [ -n "${NANOLAYER_FORCE_CLI_INSTALLATION:-}" ]; then
        devx_log__debug "NANOLAYER_FORCE_CLI_INSTALLATION set; skipping pre-existing checks"
        return 0
    fi

    local candidate=""
    if [ -z "${NANOLAYER_CLI_LOCATION:-}" ]; then
        if devx__has nanolayer; then
            devx_log__debug "Found a pre-existing nanolayer in PATH"
            candidate="nanolayer"
        fi
    elif [ -f "${NANOLAYER_CLI_LOCATION}" ] && [ -x "${NANOLAYER_CLI_LOCATION}" ]; then
        candidate="${NANOLAYER_CLI_LOCATION}"
        devx_log__debug "Found a pre-existing nanolayer from env: ${candidate}"
    fi

    [ -z "${candidate}" ] && return 0

    local raw out_norm
    if ! raw="$("${candidate}" --version 2>/dev/null)"; then
        devx_log__warn "Existing nanolayer found but failed to get version, ignoring it."
        return 0
    fi
    out_norm="$(devx_nl__extract_version_norm "${raw}")"
    if [ "${out_norm}" != "${want_norm}" ]; then
        devx_log__debug "Skipping pre-existing nanolayer (required ${required_version} != existing ${raw})"
        return 0
    fi

    printf "%s" "${candidate}"
}

devx_nl__download_and_unpack() {
    local required_version="${1:?required version is required}"
    local tar_filename tmp_dir url
    tar_filename="$(devx_nl__tar_filename)" || return 1
    tmp_dir="$(mktemp -d -t nanolayer-XXXXXXXXXX)"
    url="https://github.com/devcontainers-extra/nanolayer/releases/download/${required_version}/${tar_filename}"

    if ! devx_dl__clean_download "${url}" "${tmp_dir}/${tar_filename}"; then
        devx_log__error "Failed to download nanolayer (${url})"
        rm -rf "${tmp_dir}" || true
        return 1
    fi
    tar xfz "${tmp_dir}/${tar_filename}" -C "${tmp_dir}"
    chmod a+x "${tmp_dir}/nanolayer"
    printf "%s" "${tmp_dir}/nanolayer"
}
