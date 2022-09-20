#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

diff -s <(sort $1) <(sort $2)
#diff $1 $2 
#from https://bitbucket.oicr.on.ca/projects/GSI/repos/spb-seqware-production/browse/vidarr/workflow-template/compare.sh
