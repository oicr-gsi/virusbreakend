#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

find . -regex '.*\virusbreakend.vcf$' -exec md5sum {} \;
find . -regex '.*\virusbreakend.vcf.summary.tsv$' -exec md5sum {} \;
