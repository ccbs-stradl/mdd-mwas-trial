
log_p <- -log10(TT$P.Value)
log_p <- sort(log_p)
uni_pvalues <- runif(length(log_p))
log_uni_pvalues <- sort(-log10(uni_pvalues))

postscript(file=paste0(out, "_resid_mvalsPC_QQ.ps"), paper='a4', width=11, height=8, pagecentre=TRUE)
plot (log_uni_pvalues,log_p, xlab="Expected", ylab="Observed", main=paste(pheno, "relateds 20PC QQ"), cex.lab=1.5, cex.main=1.5)
abline(0,1)
dev.off()

jpeg(file=paste0(out, "_resid_mvalsPC_QQ.jpeg"))
plot (log_uni_pvalues,log_p, xlab="Expected", ylab="Observed", main=paste(pheno, "relateds 20PC QQ"), cex.lab=1.5, cex.main=1.5)
abline(0,1)
dev.off()

jpeg(file=paste0(out, "_resid_mvalsPC_QQ_fine.jpeg"))
plot (log_uni_pvalues,log_p, xlab="Expected", ylab="Observed", main=paste(pheno, "relateds 20PC QQ"), cex.lab=1.5, cex.main=1.5, col="red", pch='.')
abline(0,1)
dev.off()

jpeg(file=paste0(out, "_resid_mvalsPC_QQ_zoom.jpeg"))
plot (log_uni_pvalues,log_p, xlab="Expected", ylab="Observed", main=paste(pheno,  "relateds 20PC QQ"), cex.lab=1.5, cex.main=1.5, col="red", pch='.', xlim=c(0,2), ylim=c(0,2))
abline(0,1)
dev.off()

