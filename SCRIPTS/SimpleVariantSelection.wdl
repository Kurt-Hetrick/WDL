
##### Workflow ##### TUTORIAL 2 #####

# workflow helloHaplotypeCaller { # this is from the first step of the tutorial
#  call haplotypeCaller
# }

workflow SimpleVariantSelection {
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
			type="SNP",
			rawVCF=haplotypeCaller.rawVCF 
	}
	call select as selectIndels { 
		input:
			type="INDEL",
			rawVCF=haplotypeCaller.rawVCF 
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


##### TUTORIAL 1 #####
##### Workflow ##### TUTORIAL 1 #####

# workflow helloHaplotypeCaller { # this is from the first step of the tutorial
#  call haplotypeCaller
# }

