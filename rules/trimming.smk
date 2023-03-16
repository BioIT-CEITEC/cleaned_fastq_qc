rule merge_fastq_qc:
    input:  html=expand("qc_reports/{sample}/cleaned_fastqc/{read_pair_tag}_fastqc.html",sample = sample_tab.sample_name, read_pair_tag = read_pair_tags)
    output: html = "qc_reports/cleaned_fastq_multiqc.html"
    log:    "logs/merge_fastq_qc.log"
    conda:  "../wrappers/merge_fastq_qc/env.yaml"
    script: "../wrappers/merge_fastq_qc/script.py"

def cleaned_fastq_qc_input(wildcards):
    preprocessed = "cleaned_fastq"
    if read_pair_tags == ["SE"]:
        return os.path.join(preprocessed,"{sample}.fastq.gz")
    else:
        return os.path.join(preprocessed,"{sample}_{read_pair_tags}.fastq.gz")

rule cleaned_fastq_qc:
    input:  cleaned = cleaned_fastq_qc_input,
    output: html = "qc_reports/{sample}/cleaned_fastqc/{read_pair_tags}_fastqc.html",
    log:    "logs/{sample}/cleaned_fastqc_{read_pair_tags}.log"
    params: extra = "--noextract --format fastq --nogroup",
    threads:  2
    conda:  "../wrappers/cleaned_fastq_qc/env.yaml"
    script: "../wrappers/cleaned_fastq_qc/script.py"

def raw_fastq_qc_input(wildcards):
    preprocessed = "raw_fastq"
    if read_pair_tags == ["SE"]:
        return os.path.join(preprocessed,"{sample}.fastq.gz")
    else:
        return [os.path.join(preprocessed,"{sample}_R1.fastq.gz"),os.path.join(preprocessed,"{sample}_R2.fastq.gz")]

rule preprocess:
    input:  raw = expand("raw_fastq/{{sample}}{read_tags}.fastq.gz",read_tags=pair_tag),
    output: cleaned = expand("cleaned_fastq/{{sample}}{read_tags}.fastq.gz",read_tags=pair_tag),
    log:    "logs/{sample}/pre_alignment_processing.log"
    threads: 10
    resources:  mem = 10
    params: adaptors = config["trim_adapters"],
            r1u = "cleaned_fastq/trimmed/{sample}_R1.discarded.fastq.gz",
            r2u = "cleaned_fastq/trimmed/{sample}_R2.discarded.fastq.gz",
            trim_left1 = config["trim_left1"], # Applied only if trim left is true, trimming from R1 (different for classic:0, quant:10, sense:9)
            trim_right1 = config["trim_right1"], # Applied only if trim right is true, trimming from R1; you should allow this if you want to trim the last extra base and TRIM_LE is true as RD_LENGTH is not effective
            trim_left2 = config["trim_left2"], # Applied only if trim left is true, trimming from R2 (different for classic:0, quant:?, sense:7)
            trim_right2 = config["trim_right2"], # Applied only if trim right is true, trimming from R2; you should allow this if you want to trim the last extra base and TRIM_LE is true as RD_LENGTH is not effective
            phred = "-phred33",
            leading = 3,
            trailing = 3,
            crop = 250,
            minlen = config["min_length"],
            slid_w_1 = 4,
            slid_w_2 = 5,
            trim_stats = "qc_reports/{sample}/trimmomatic/trim_stats.log"
    conda:  "../wrappers/preprocess/env.yaml"
    script: "../wrappers/preprocess/script.py"

