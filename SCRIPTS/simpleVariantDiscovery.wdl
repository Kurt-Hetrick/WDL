
##### Workflow ##### TUTORIAL 3 #####

workflow SimpleVariantDiscovery {
  File gatk
  File refFasta
  File refIndex
  File refDict
  String name

	call haplotypeCaller { 
		input:
			sampleName=name, 
			RefFasta=refFasta, 
			GATK=gatk, 
			RefIndex=refIndex, 
			RefDict=refDict
	}
	call select as selectSNPs { 
		input:
			sampleName=name,
			type="SNP",
			RefFasta=refFasta, 
      GATK=gatk, 
      RefIndex=refIndex, 
      RefDict=refDict, 
			rawVCF=haplotypeCaller.rawVCF 
	}
	call select as selectIndels { 
		input:
			type="INDEL",
			sampleName=name,
			RefFasta=refFasta, 
      GATK=gatk, 
      RefIndex=refIndex, 
      RefDict=refDict, 
			rawVCF=haplotypeCaller.rawVCF 
	}
  call hardFilterSNP { 
  	input: 
  		sampleName=name, 
      RefFasta=refFasta, 
      GATK=gatk, 
      RefIndex=refIndex, 
      RefDict=refDict, 
      rawSNPs=selectSNPs.rawSubset
  }
  call hardFilterIndel { 
  	input: 
  		sampleName=name, 
      RefFasta=refFasta, 
      GATK=gatk, 
      RefIndex=refIndex, 
      RefDict=refDict, 
  		rawIndels=selectIndels.rawSubset
  	}
  call combine { 
  	input: 
  		sampleName=name, 
      RefFasta=refFasta, 
      GATK=gatk, 
      RefIndex=refIndex, 
      RefDict=refDict, filteredSNPs=hardFilterSNP.filteredSNPs,
  		filteredIndels=hardFilterIndel.filteredIndels
  }
}

##### Task #####

##### After this was done in the first part of the tutorial it was used again the 2nd part #####
##### Hence all of the linking in the workflow #####

task haplotypeCaller {
	File GATK
	File RefFasta
	File RefIndex
	File RefDict
	String sampleName
	File inputBAM
	File bamIndex
	command {
	java -jar ${GATK} \
		-T HaplotypeCaller \
		-R ${RefFasta} \
		-I ${inputBAM} \
		-L 20 \
		-o ${sampleName}.raw.indels.snps.vcf
}
	output {
		File rawVCF = "${sampleName}.raw.indels.snps.vcf"
	}
}

task select {
  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  String type
  File rawVCF

  command {
    java -jar ${GATK} \
      -T SelectVariants \
      -R ${RefFasta} \
      -V ${rawVCF} \
      -selectType ${type} \
      -o ${sampleName}_raw.${type}.vcf
  }
  output {
    File rawSubset = "${sampleName}_raw.${type}.vcf"
  }
}

task hardFilterSNP {
  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File rawSNPs

  command {
    java -jar ${GATK} \
      -T VariantFiltration \
      -R ${RefFasta} \
      -V ${rawSNPs} \
      --filterExpression "FS > 60.0" \
      --filterName "snp_filter" \
      -o ${sampleName}.filtered.snps.vcf
  }
  output {
    File filteredSNPs = "${sampleName}.filtered.snps.vcf"
  }
}

task hardFilterIndel {
  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File rawIndels

  command {
    java -jar ${GATK} \
      -T VariantFiltration \
      -R ${RefFasta} \
      -V ${rawIndels} \
      --filterExpression "FS > 200.0" \
      --filterName "indel_filter" \
      -o ${sampleName}.filtered.indels.vcf
  }
  output {
    File filteredIndels = "${sampleName}.filtered.indels.vcf"
  }
}

task combine {
  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File filteredSNPs
  File filteredIndels

  command {
    java -jar ${GATK} \
      -T CombineVariants \
      -R ${RefFasta} \
      -V ${filteredSNPs} \
      -V ${filteredIndels} \
      --genotypemergeoption UNSORTED \
      -o ${sampleName}.filtered.snps.indels.vcf
  }
  output {
    File filteredVCF = "${sampleName}.filtered.snps.indels.vcf"
  }
}

##### Workflow ##### TUTORIAL 2 #####

# workflow helloHaplotypeCaller { # this is from the first step of the tutorial
#  call haplotypeCaller
# }

# workflow SimpleVariantSelection { # This is from the second step of the tutorial
# 	File gatk
# 	File refFasta
# 	File refIndex
# 	File refDict
# 	String name
# 
# 	call haplotypeCaller { 
# 		input:
# 			sampleName=name, 
# 			RefFasta=refFasta, 
# 			GATK=gatk, 
# 			RefIndex=refIndex, 
# 			RefDict=refDict
# 	}
# 	call select as selectSNPs { 
# 		input:
# 			type="SNP",
# 			rawVCF=haplotypeCaller.rawVCF 
# 	}
# 	call select as selectIndels { 
# 		input:
# 			type="INDEL",
# 			rawVCF=haplotypeCaller.rawVCF 
# 	}
# }

##### TUTORIAL 1 #####
##### Workflow ##### TUTORIAL 1 #####

# workflow helloHaplotypeCaller { # this is from the first step of the tutorial
#  call haplotypeCaller
# }

