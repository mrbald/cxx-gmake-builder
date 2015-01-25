#!/bin/bash

set -eu

cd ${BASH_SOURCE[0]%/*} >/dev/null 2>&1
readonly mydir=${PWD}
cd - >/dev/null 2>&1

mkdir -p $1
cd $1
make -f ${mydir}/makefile launcher
bin/launcher
