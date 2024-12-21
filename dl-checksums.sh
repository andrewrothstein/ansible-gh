#!/usr/bin/env sh
set -e
DIR=~/Downloads
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
    local url=$MIRROR/v$ver/$file
    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(grep $file $lchecksums | awk '{print $1}')
}

dl_ver() {
    local ver=$1
    local checksums="gh_${ver}_checksums.txt"
    local url=$MIRROR/v$ver/$checksums
    local lchecksums=$DIR/$checksums
    if [ ! -e $lchecksums ];
    then
        curl -sSLf -o $lchecksums $url
    fi

    printf "  # %s\n" $url
    printf "  '%s':\n" $ver

    dl $ver $lchecksums linux 386
    dl $ver $lchecksums linux amd64
    dl $ver $lchecksums linux arm64
    dl $ver $lchecksums linux armv6
    dl $ver $lchecksums macOS amd64 zip
    dl $ver $lchecksums macOS arm64 zip
    dl $ver $lchecksums windows 386 zip
    dl $ver $lchecksums windows amd64 zip
}

dl_ver ${1:-2.64.0}

