
workflow jointCallingGenotypes {

  File inputSamplesFile # tab delimited text file containing 1) sample name 2) path to bam 3) path to bam index # no header
  Array[Array[File]] inputSamples = read_tsv(inputSamplesFile)
  File gatk
  File refFasta
  File refIndex
  File refDict

  scatter (sample in inputSamples) { # gathering is implied
    call HaplotypeCallerERC {
      input: 
      	GATK=gatk, 
        RefFasta=refFasta, 
        RefIndex=refIndex, 
        RefDict=refDict, 
        sampleName=sample[0],
        bamFile=sample[1], 
        bamIndex=sample[2]
    }
  }
  call GenotypeGVCFs {
    input: 
    	GATK=gatk, 
      RefFasta=refFasta, 
      RefIndex=refIndex, 
      RefDict=refDict, 
      sampleName="CEUtrio", 
      GVCFs=HaplotypeCallerERC.GVCF
  }
}

##### TASK SECTION #####

task HaplotypeCallerERC {

  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File bamFile
  File bamIndex

  command {
    java -jar ${GATK} \
        -T HaplotypeCaller \
        -ERC GVCF \
        -R ${RefFasta} \
        -I ${bamFile} \
        -L 20 \
        -o ${sampleName}_rawLikelihoods.g.vcf
  }
  output {
    File GVCF = "${sampleName}_rawLikelihoods.g.vcf"
  }
}

task GenotypeGVCFs {

  File GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  Array[File] GVCFs # FILE GVCF IS THE OUTPUT FROM THE HAPLOTYPECALLERERC TASK ABOVE.

  command {
    java -jar ${GATK} \
        -T GenotypeGVCFs \
        -R ${RefFasta} \
        -V ${sep=" -V " GVCFs} \
        -o ${sampleName}_rawVariants.vcf
  }
  output {
    File rawVCF = "${sampleName}_rawVariants.vcf"
  }
}
