version 1.0

workflow virusbreakend {

  input {
    File inputBam
    File indexBam
  }

  parameter_meta {
    inputBam: "STAR BAM aligned to genome"
    indexBam: "Index for STAR Bam file"
  }

  call runVirusbreakend {
    input:
    inputBam = inputBam,
    indexBam = indexBam
}

  output {
    File fusionsPredictions     = runArriba.fusionPredictions
    File fusionDiscarded        = runArriba.fusionDiscarded
    File fusionFigure           = runArriba.fusionFigure
  }

  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow that takes the Bam output from STAR and detects RNA-seq fusion events. It is required to run STAR with the option --chimOutType 'WithinBAM HardClip Junctions' as per https://github.com/oicr-gsi/star to create a BAM file compatible with both the arriba and STARFusion workflows. For additional parameter suggestions please see the arriba github link below."
    dependencies: [
    {
       name: "arriba/2.0",
       url: "https://github.com/suhrig/arriba"
     }
    ]
  }
}

task runVirusbreakend {
  input {
    File   inputBam
    File   indexBam
    String modules = "gridss-conda/2.13.2 virusbreakenddb/20210401 hmftools-data/hg38"
    String database = "$VIRUSBREAKEND_DB_ROOT/"
    String genome = "$HMFTOOLS_DATA_ROOT/hg38_random.fa"
    String gridss = "$GRIDSS_CONDA_ROOT/share/gridss-2.13.2-1/gridss.jar"
    Int threads = 8
    Int jobMemory = 64
    Int timeout = 72
  }

  parameter_meta {
    inputBam: "WGS bam"
    indexBam: "WGS bam index"
    modules: "Names and versions of modules to load"
    genome: "Path to loaded genome"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  command <<<
      set -euo pipefail

      virusbreakend \
      --jar {gridss} \
      --kraken2db {database} \
      --reference {genome} \
      --output virusbreakend.vcf \
      {inputBam}

  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File fusionPredictions        = "~{outputFileNamePrefix}.fusions.tsv"
      File fusionDiscarded          = "~{outputFileNamePrefix}.fusions.discarded.tsv"
      File fusionFigure             = "~{outputFileNamePrefix}.fusions.pdf"
  }

  meta {
    output_meta: {
      fusionPredictions: "Fusion output tsv",
      fusionDiscarded:   "Discarded fusion output tsv",
      fusionFigure: "PDF rendering of candidate fusions"
    }
  }
}
