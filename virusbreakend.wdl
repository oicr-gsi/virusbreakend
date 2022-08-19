version 1.0

workflow virusbreakend {
  input {
    File tumorBam
    File tumorBai
    File normalBam
    File normalBai
  }

  parameter_meta {
    tumorBam: "Input tumor file (bam or sam)."
    normalBam: "Input normal file (bam or sam)."
  }

  meta {
    author: "Felix Beaudry and Alexander Fortuna"
    email: "fbeaudry@oicr.on.ca"
    description: "performs somatic genomic rearrangement detection and classification"
    dependencies: [
    {
      name: "VIRUSBreakend",
      url: "https://github.com/PapenfussLab/gridss/blob/master/VIRUSBreakend_Readme.md"
    }
    ]
  }
  
  call virusBreakend {
  
  }

  output {
  }
}

task virusbreakend {
  input {
    String modules = "argparser stringdist structuravariantannotation rtracklayer gridss/2.13.2 hg38/p12 hmftools/1.0 kraken2 bcftools hmftools-data/hg38"
    String refFasta = "$HMFTOOLS_DATA_ROOT/hg38_random.fa"
    File normBam
    File normBai
    File tumorBam
    File tumorBai
    File gcProfile = ${HMFTOOLS_DATA_ROOT}/GC_profile.1000bp.38.cnp
    String gamma = 100
    Int threads = 8
    Int memory = 8
    Int timeout = 100
  }

  command <<<
    set -euo pipefail

    $GRIDSS_ROOT/virusbreakend \
      --kraken2db $VIRUSBREAKEND_DB_ROOT/ \
      --reference ${testDir}/hg38_random.fa \
      --output ${sample}.virusbreakend.vcf \
      ${sample}.bam

  >>>

  runtime {
    cpu: "~{threads}"
    memory:  "~{memory} GB"
    modules: "~{modules}"
    timeout: "~{timeout}"
  }

  output {
    File unfilteredVcf = "~{outputVcf}.allocated.vcf"
  }
}