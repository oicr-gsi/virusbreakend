#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

diff $1 $2

#tmbAnalysis --> diff -s <(sort $1) <(sort $2)
