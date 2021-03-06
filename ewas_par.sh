#! /usr/bin/bash
#$ -l h_rt=0:10:00
#$ -l h_vmem=30G
#$ -t 1-22
#$ -cwd
#$ -o logs
#$ -e logs
#$ -b y

script_dir=$(dirname $0)

. /etc/profile.d/modules.sh

module load igmm/apps/R/3.4.1

Rscript $script_dir/ewas_par.R $*

#F_MVALS="ForAna_GRM_corrected_Mvalues.rds"
#F_PCA="Konrad_Corrected_resid_mvals_relateds_PCA_301017.rds"
#F_PROBES="SNP_CH_probes"
