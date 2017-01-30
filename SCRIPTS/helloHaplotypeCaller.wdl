
##### Workflow #####

workflow helloHaplotypeCaller {
	call haplotypeCaller
}

##### Task #####

# Base cmd line
# java -jar GenomeAnalysisTK.jar \
# 	-T HaplotypeCaller \
# 	-R reference.fasta \
# 	-I input.bam \
# 	-i output.vcf

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
		-o ${sampleName}.raw.indels.snps.vcf
}
	output {
		File rawVCF = "${sampleName}.raw.indels.snps.vcf"
	}
}
