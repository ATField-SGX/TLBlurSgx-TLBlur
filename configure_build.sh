#!/usr/bin/env bash
# Configure the Meson build. Toolchain binaries come from PATH.
# TLBLUR_LLVM, or ./llvm/install when that tree exists, is placed first.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)

if [[ -n ${TLBLUR_LLVM:-} ]]; then
  llvm_bin=$TLBLUR_LLVM/bin
elif [[ -x $root/llvm/install/bin/clang ]]; then
  llvm_bin=$root/llvm/install/bin
else
  llvm_bin=
fi

if [[ -n $llvm_bin ]]; then
  if [[ ! -x $llvm_bin/clang ]]; then
    echo "TLBlur LLVM not found at $llvm_bin" >&2
    exit 1
  fi
  export PATH="$llvm_bin:$PATH"
fi

missing=()
for tool in clang clang++ ld.lld llvm-ar llvm-strip llvm-bolt llvm-objcopy; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing+=("$tool")
  fi
done
if ((${#missing[@]})); then
  echo "missing ${missing[*]}" >&2
  echo "put the TLBlur LLVM bin directory on PATH, or set TLBLUR_LLVM" >&2
  exit 1
fi

meson setup \
  -Dsgx_sim=false \
  -Dprefix="$root/install" \
  -Dlibdir=lib \
  --native-file "$root/meson-clang.ini" \
  "$root/build"
