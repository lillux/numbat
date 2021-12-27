# Numbat

<img src="logo.png" align="right" width="200">

Numbat is a haplotype-enhanced CNV caller from single-cell transcriptomics data. It integrates gene expression, allele ratio, and haplotype phasing signals from the human population to accurately profile CNVs in single-cells and infer their lineage relationship. 

Numbat can be used to 1. detect allele-specific copy number variations from single-cells 2. differentiate tumor versus normal cells in the tumor microenvironment 3. infer the clonal architecture and evolutionary history of profiled tumors. 

Numbat does not require paired DNA or genotype data and operates solely on the donor scRNA-data data (for example, 10x Cell Ranger output).

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)

A more detailed vignette for interpreting Numbat results is available:
- [Walkthrough](http://pklab.med.harvard.edu/teng)

# Prerequisites
Numbat uses cellsnp-lite for generating SNP pileup data and eagle2 for phasing. Please follow their installation instructions and make sure their binary executables can be found in your $PATH.

1. [cellsnp-lite](https://github.com/single-cell-genetics/cellsnp-lite)
2. [eagle2](https://alkesgroup.broadinstitute.org/Eagle/)

Additionally, Numbat needs a common SNP VCF and phasing reference panel. You can use the 1000 Genome reference below:

3. 1000G SNP reference file 
```
# hg38
wget https://sourceforge.net/projects/cellsnp/files/SNPlist/genome1K.phase3.SNP_AF5e2.chr1toX.hg38.vcf.gz
# hg19
wget https://sourceforge.net/projects/cellsnp/files/SNPlist/genome1K.phase3.SNP_AF5e2.chr1toX.hg19.vcf.gz
```
4. 1000G Reference Panel
```
# hg38
wget http://pklab.med.harvard.edu/teng/data/1000G_hg38.zip
# hg19
wget http://pklab.med.harvard.edu/teng/data/1000G_hg19.zip
```

# Installation
Install the Numbat R package via:
```
git clone https://github.com/kharchenkolab/Numbat.git
```
Within R,
```
devtools::install_local("./Numbat")
```

# Usage
1. Run the preprocessing script (`pileup_and_phase.r`): collect allele data and phase SNPs
```
usage: pileup_and_phase.r [-h] [--label LABEL] [--samples SAMPLES]
                          [--bams BAMS] [--barcodes BARCODES] [--gmap GMAP]
                          [--snpvcf SNPVCF] [--paneldir PANELDIR]
                          [--outdir OUTDIR] [--ncores NCORES]
                          [--UMItag UMITAG] [--cellTAG CELLTAG]

Run SNP pileup and phasing with 1000G

optional arguments:
  -h, --help           show this help message and exit
  --label LABEL        Individual label
  --samples SAMPLES    Sample names, comma delimited
  --bams BAMS          BAM files, one per sample, comma delimited
  --barcodes BARCODES  Cell barcodes, one per sample, comma delimited
  --gmap GMAP          Path to genetic map provided by Eagle2
  --snpvcf SNPVCF      SNP VCF for pileup
  --paneldir PANELDIR  Directory to phasing reference panel (BCF files)
  --outdir OUTDIR      Output directory
  --ncores NCORES      Number of cores
  --UMItag UMITAG      UMI tag in bam. Should be Auto for 10x and None for
                       Slide-seq
  --cellTAG CELLTAG    Cell tag in bam. Should be CB for 10x and XC for Slide-
                       seq
```

2. Run Numbat

In this example (ATC2 from [Gao et al](https://www.nature.com/articles/s41587-020-00795-2)), the gene expression count matrix and allele dataframe are already prepared for you.
```
library(numbat)

# run
out = numbat_subclone(
    count_mat_ATC2, # gene x cell raw UMI count matrix 
    ref_hca, # reference expression profile, a genes x cell type matrix
    df_allele_ATC2, # allele dataframe generated by pileup_and_phase script
    gtf_transcript, # provided upon loading the package
    genetic_map_hg38, # provided upon loading the package
    min_cells = 20,
    t = 1e-6,
    ncores = 20,
    init_k = 3,
    max_cost = 150,
    out_dir = glue('~/results/test')
)
```
3. Visualize results

Numbat generates a number of files in the output folder. The main results can be loaded by this function:
```
res = fetch_results(out_dir, i = 2)
```

Now we can visualize the single-cell CNV profiles and lineage relationships:
```
plot_sc_joint(
    res$gtree,
    res$joint_post,
    res$segs_consensus,
    tip_length = 2,
    branch_width = 0.2,
    size = 0.3
) +
ggtitle('ATC2')
```
![image](https://user-images.githubusercontent.com/13375875/144479138-0cf007cd-a979-4910-835d-fd20b920ba67.png)


