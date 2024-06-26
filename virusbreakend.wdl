version 1.0

workflow virusbreakend {

  input {
    File inputBam
    File indexBam
    String outputFileNamePrefix
    String reference
  }

  parameter_meta {
    inputBam: "WGS BMPP BAM aligned to genome"
    indexBam: "Index for WGS BMPP Bam file"
    outputFileNamePrefix: "prefix for the output file name"
    reference: "The genome reference build. For example: hg19, hg38, mm10"
  }

  if (reference == "hg38") {
          String hg38DataModules = "virusbreakend-db/20210401 hmftools-data/hg38"
          String hg38Genome = "$HMFTOOLS_DATA_ROOT/hg38_random.fa"
  }

  String data_Modules = select_first([hg38DataModules])
  String genome = select_first([hg38Genome])

  call runVirusbreakend {
    input:
    inputBam = inputBam,
    indexBam = indexBam,
    outputFileNamePrefix = outputFileNamePrefix,
    genome = genome,
    dataModules = data_Modules
}

  output {
    File integrationbreakpointvcf     = runVirusbreakend.integrationbreakpointvcf
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
    output_meta: {
      integrationbreakpointvcf: {
        description: "Breakpoints, vcf file",
        vidarr_label: "integrationbreakpointvcf"
      },
      outputsummary: {
        description: "Output summary",
        vidarr_label: "outputsummary"
      }
    }
  }
}

task runVirusbreakend {
  input {
    File   inputBam
    File   indexBam
    String outputFileNamePrefix
    String genome
    String dataModules
    String modules = "gridss-conda/2.13.2"
    String database = "$VIRUSBREAKEND_DB_ROOT/"
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
    dataModules: "Names and versions of data modules to load"
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
    modules: "~{modules} ~{dataModules}"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }

  output {
      File integrationbreakpointvcf       = "~{outputFileNamePrefix}.virusbreakend.vcf"
      File outputsummary = "~{outputFileNamePrefix}.virusbreakend.vcf.summary.tsv"
  }

  
}
