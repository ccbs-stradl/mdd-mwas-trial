# find location of this script
all_args <- commandArgs(trailingOnly = FALSE)
file_flag <- "--file="
script_path <- sub(file_flag, "", all_args[grep(file_flag, all_args)])
script_dir <- dirname(script_path)

.libPaths(file.path(script_dir, 'Rlibrary'))

library(optparse)
library(limma)
library(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)

source(file.path(script_dir, 'eBayes2.R'))

parse <- OptionParser()

option_list <- list(
make_option('--out', type='character', help="Output prefix", action='store'),
make_option('--pheno', type='character', help="Phenotype", action='store'),
make_option('--pdata', type='character', help="Phenotype data", action='store'),
make_option('--working', type='character', help='Working directory', action='store'))

args = commandArgs(trailingOnly=TRUE)

opt <- parse_args(OptionParser(option_list=option_list), args=args)



out <- opt$out
working <- opt$working
pheno <- opt$pheno

logging <- function(str) cat(paste0(str, "\n"), file=paste(out, 'log', sep='.'), append=TRUE);

# check that there are intermediate output files for each chromosome
# if error, print job output to log
job_error <- FALSE
for(i in 1:22) {

        if(! file.exists(file.path(working, paste(i, 'rds', sep='.')))) {
                
                logging('###################################') 
                logging('###################################') 
                logging('###################################') 
                logging(paste0('Chromosome ', i, ' missing.'))


                job_stdout <- Sys.getenv('SGE_STDOUT_PATH')
                job_stderr <- Sys.getenv('SGE_STDERR_PATH')

                job_stderr_file <- file(job_stderr, 'r')
                job_stdout_file <- file(job_stdout, 'r')

                logging(readLines(job_stdout_file))
                logging(readLines(job_stderr_file))
                logging('###################################') 
                logging('###################################') 
                logging('###################################') 

                close(job_stdout_file)
                close(job_stderr_file)

                job_error <- TRUE

        }

}

if(job_error) {
        stop('Missing job outputs')
}

# load model fits from each chromosome
fits_chr <- lapply(1:22, function(i) readRDS(file.path(working, paste(i, 'rds', sep='.'))))

# merge into a single MArrayLM
names(fits_chr[[1]])

fits <- 
new("MArrayLM",
list(
coefficients=do.call(rbind, lapply(fits_chr, function(m) m[['coefficients']])),
rank=fits_chr[[1]]$rank,
qr=fits_chr[[1]]$qr,
df.residual=do.call(c, lapply(fits_chr, function(m) m[['df.residual']])),
sigma=do.call(c, lapply(fits_chr, function(m) m[['sigma']])),
cov.coefficients=fits_chr[[1]]$cov.coefficients,
stdev.unscaled=do.call(rbind, lapply(fits_chr, function(m) m[['stdev.unscaled']])),
pivot=fits_chr[[1]]$pivot,
Amean=do.call(c, lapply(fits_chr, function(m) m[['Amean']])),
method=fits_chr[[1]]$method,
design=fits_chr[[1]]$design))


efit <- eBayes2(fits)	

TT <- topTable(efit, coef=2, adjust='fdr', number=length(fits$Amean))

TT$ID<-rownames(TT)

# Merge the annotation data
anno <- getAnnotation(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
genes <- data.frame(ID=anno$Name, geneSymbol=anno$UCSC_RefGene_Name, CHR=anno$chr, MAPINFO=anno$pos, FEATURE=anno$UCSC_RefGene_Group, CpGISLAND=anno$Relation_to_Island)
TT_anno <-merge(genes, TT, by="ID", all.y=TRUE)

TT_anno$df <- fits$df.residual

write.table(TT_anno, file=paste0(out, ".toptable.txt"), sep="\t", row.names=FALSE)

IF <- median(TT$t^2)/0.4549
logging(paste0("Inflation factor for 20 PC: ", IF))
