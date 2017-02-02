workflow MultiOutMultiInExample {

  File inputVCF

  call splitVcfs { input: VCF=inputVCF }
  call CombineVariants { input: VCF1=splitVcfs.indelOut, VCF2=splitVcfs.snpOut }
}

task splitVcfs {

  File VCF

  command {
    java -jar picard.jar SplitVcfs \
        I=${VCF} \
        SNP_OUTPUT=snp.vcf \
        INDEL_OUTPUT=indel.vcf
  }
  output {
    File snpOut = "snp.vcf"
    File indelOut = "indel.vcf"
  }
}

task CombineVariants {

  File VCF1
  File VCF2

  command {
    java -jar GenomeAnalysisTK.jar \
        -T CombineVariants
        -R reference.fasta \
        -V ${VCF1} \
        -V ${VCF2} \
        --genotypemergeoption UNSORTED \
        -o combined.vcf
  }
  output {
    File VCF = "combined.vcf"
  }
}
