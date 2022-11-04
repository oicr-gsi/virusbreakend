#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

diff $1 $2 
