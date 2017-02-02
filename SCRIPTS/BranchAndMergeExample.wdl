workflow BranchAndMergeExample {

  File originalBAM

  call splitVcfs { input: VCF=originalBAM }
  call FilterSNP { input: VCF=splitVcfs.snpOut }
  call FilterIndel { input: VCF=splitVcfs.indelOut }
  call CombineVariants { input: VCF1=FilterSNP.filteredVCF, VCF2=FilterIndel.filteredVCF }
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

task FilterSNP {

  File VCF

  command {
    java -jar GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R reference.fasta \
        -V ${VCF} \
        --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
        --filterName "snp_filter" \
        -o filteredSNP.vcf
  }
  output {
    File filteredVCF = "filteredSNP.vcf"
  }
}

task FilterIndel {

  File VCF

  command {
    java -jar GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R reference.fasta \
        -V ${VCF} \
        --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum <-20.0" \
        --filterName "indel_filter" \
        -o filteredIndel.vcf
  }
  output {
    File filteredVCF = "filteredIndel.vcf"
  }
}

task CombineVariants {

  File VCF1
  File VCF2

  command {
    java -jar GenomeAnalysisTK.jar \
        -T CombineVariants \
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
