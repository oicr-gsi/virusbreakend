# virusbreakend

Workflow that takes the Bam output from BMPP and reports viral integration sites.

## Overview

## Dependencies

* [virusbreakend](https://doi.org/10.1093/bioinformatics/btab343)
* [gridss](https://github.com/PapenfussLab/gridss)


## Usage

### Cromwell
```
java -jar cromwell.jar run virusbreakend.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`inputBam`|File|WGS BMPP BAM aligned to genome
`indexBam`|File|Index for WGS BMPP Bam file
`outputFileNamePrefix`|String|prefix for the output file name
`reference`|String|The genome reference build. For example: hg19, hg38, mm10


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runVirusbreakend.modules`|String|"gridss-conda/2.13.2"|Names and versions of modules to load
`runVirusbreakend.database`|String|"$VIRUSBREAKEND_DB_ROOT/"|a database of viral and bacterial sequences
`runVirusbreakend.gridss`|String|"$GRIDSS_CONDA_ROOT/share/gridss-2.13.2-1/gridss.jar"|the full path to the gridss jar file
`runVirusbreakend.threads`|Int|8|Requested CPU threads
`runVirusbreakend.jobMemory`|Int|64|Memory allocated for this job
`runVirusbreakend.timeout`|Int|72|Hours before task timeout


### Outputs

Output | Type | Description | Labels
---|---|---|---
`integrationbreakpointvcf`|File|{'description': 'A VCF containing the integration breakpoints', 'vidarr_label': 'integrationbreakpointvcf'}|
`outputsummary`|File|{'description': 'a summary of results from the virusbreakend workflow', 'vidarr_label': 'outputsummary'}|


## Commands
This section lists command(s) run by VIRUSBreakend workflow
 
* Running VIRUSBreakend
 
VIRUSBreakend is a high-speed viral integration detection tool designed to be incorporated in the whole genome sequence piplines with minimal additional resources. This tool is part of GRIDSS - the Genomic Rearrangement IDentification Software Suite.
 
```
       set -euo pipefail
 
       virusbreakend \
       --jar ~{gridss} \
       --kraken2db ~{database} \
       --reference ~{genome} \
       --output ~{outputFileNamePrefix}.virusbreakend.vcf \
       ~{inputBam}
 
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
