version 1.0

workflow virusbreakend {

  input {
    File inputBam
    File indexBam
    String outputFileNamePrefix
  }

  parameter_meta {
    inputBam: "WGS BMPP BAM aligned to genome"
    indexBam: "Index for WGS BMPP Bam file"
    outputFileNamePrefix: "prefix for the output file name"
  }

  call runVirusbreakend {
    input:
    inputBam = inputBam,
    indexBam = indexBam,
    outputFileNamePrefix = outputFileNamePrefix
}

  output {
    File integrationbreakpointvcf     = runVirusbreakend.integrationbreakpointvcf
    File kraken2report        = runVirusbreakend.coveragestats
    File coveragestats           = runVirusbreakend.coveragestats
    File outputsummary = runVirusbreakend.outputsummary
  }

  meta {
    author: "Alexander Fortuna and Felix Beaudry"
    email: "alexander.fortuna@oicr.on.ca & felix.beaudry@oicr.on.ca"
    description: "Workflow that takes the Bam output from BMPP and reports viral integration sites."
    dependencies: [
    {
       name: "virusbreakend",
       url: "https://doi.org/10.1093/bioinformatics/btab343"
     },
     {
       name: "gridss",
       url: "https://github.com/PapenfussLab/gridss"
     }
    ]
  }
}

task runVirusbreakend {
  input {
    File   inputBam
    File   indexBam
    String modules = "gridss-conda/2.13.2 virusbreakend-db/20210401 hmftools-data/hg38"
    String outputFileNamePrefix
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
    outputFileNamePrefix: "output filename"
    modules: "Names and versions of modules to load"
    genome: "Path to loaded genome"
    database: "a database of viral and bacterial sequences"
    gridss: "the full path to the gridss jar file"
    threads: "Requested CPU threads"
    jobMemory: "Memory allocated for this job"
    timeout: "Hours before task timeout"
  }

  command <<<
      set -euo pipefail

      virusbreakend \
      --jar ~{gridss} \
      --kraken2db ~{database} \
      --reference ~{genome} \
      --output ~{outputFileNamePrefix}.virusbreakend.vcf \
      ~{inputBam}

  >>>

  runtime {
    memory:  "~{jobMemory} GB"
    modules: "~{modules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File integrationbreakpointvcf       = "~{outputFileNamePrefix}.virusbreakend.vcf"
      File outputsummary = "~{outputFileNamePrefix}.virusbreakend.vcf.summary.tsv"
      File kraken2report         = "~{outputFileNamePrefix}.virusbreakend.vcf.virusbreakend.working/~{outputFileNamePrefix}.virusbreakend.vcf.kraken2.report.viral.txt"
      File coveragestats            = "~{outputFileNamePrefix}.virusbreakend.vcf.virusbreakend.working/~{outputFileNamePrefix}.virusbreakend.vcf.summary.coverage.tsv"
  }

  meta {
    output_meta: {
      outputsummary: "a summary of results from the virusbreakend workflow",
      integrationbreakpointvcf: "A VCF containing the integration breakpoints",
      kraken2report: "The kraken2 report of the virus(es) for which viral integration was run upon",
      coveragestats: "Coverage statistics of the virus(es) for which viral integration was run upon"
    }
  }
}
