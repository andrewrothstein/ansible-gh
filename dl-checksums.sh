#!/usr/bin/env sh
set -e
DIR=$(mktemp -d)
trap 'rm -rf "$DIR"' EXIT
MIRROR=https://github.com/cli/cli/releases/download

# https://github.com/cli/cli/releases/download/v1.12.1/gh_1.12.1_checksums.txt
# https://github.com/cli/cli/releases/download/v1.12.1/gh_1.12.1_linux_amd64.tar.gz

dl() {
    local ver=$1
    local lchecksums=$2
    local os=$3
    local arch=$4
    local archive_type=${5:-tar.gz}
    local platform="${os}_${arch}"
    local file="gh_${ver}_${platform}.${archive_type}"
    local url="$MIRROR/v$ver/$file"
    local sum
    sum=$(awk -v f="$file" '$2 == f || $2 == "*" f {print $1}' "$lchecksums")
    if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'
    then
        echo "bad or missing checksum for $file: '$sum'" >&2
        exit 1
    fi
    printf "    # %s\n" "$url"
    printf "    %s: sha256:%s\n" "$platform" "$sum"
}

dl_ver() {
    local ver=$1
    local checksums="gh_${ver}_checksums.txt"
    local url="$MIRROR/v$ver/$checksums"
    local lchecksums="$DIR/$checksums"
    curl -fsSL --proto '=https' --tlsv1.2 -o "$lchecksums" "$url"

    printf "  # %s\n" "$url"
    printf "  '%s':\n" "$ver"

    dl "$ver" "$lchecksums" linux 386
    dl "$ver" "$lchecksums" linux amd64
    dl "$ver" "$lchecksums" linux arm64
    dl "$ver" "$lchecksums" linux armv6
    dl "$ver" "$lchecksums" macOS amd64 zip
    dl "$ver" "$lchecksums" macOS arm64 zip
    dl "$ver" "$lchecksums" windows 386 zip
    dl "$ver" "$lchecksums" windows amd64 zip
}

dl_ver "${1:-2.105.0}"
