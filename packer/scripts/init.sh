#!/bin/bash
set -e

if [ -z "${1}" ]; then
  1>&2 echo "Usage: init.sh <base directory>"
  exit 1
else
  BASE="${1}"
fi

mkdir -p ${BASE}/dist ${BASE}/build/tmp ${BASE}/build/usr/src
chmod a+rwxt ${BASE}/build/tmp
ROOT_PATH="$(realpath "$(dirname ${0})/..")"
ln -fs ${ROOT_PATH} ${BASE}/packer
