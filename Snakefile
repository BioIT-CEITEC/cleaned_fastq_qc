import os
import pandas as pd
import json
from snakemake.utils import min_version

min_version("5.18.0")
configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]

##### Config processing #####
# Samples
#

sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")

if not config["is_paired"]:
    read_pair_tags = ["SE"]
    pair_tag = [""]
    paired = "SE"
else:
    read_pair_tags = ["R1","R2"]
    pair_tag = ["_R1","_R2"]
    paired = "PE"

wildcard_constraints:
    sample = "|".join(sample_tab.sample_name)

##### Target rules #####
rule all:
    input: "qc_reports/cleaned_fastq_multiqc.html"

##### Modules #####

include: "rules/trimming.smk"
