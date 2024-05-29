###################################### NEXTFLOW #########################################
# In next flow it seems that we create inputs and ouput modules / processes and channels 
# Channels are defined and become inputs when a process is called  
# Inputs are a declarations to the kind of variable something is  
# when a process creates something these must alos be named hence the output section  
# Inputs by way of Channels can be Images as well as Sequence Data
###########################################################################################  
# Python will run things sequentialy but NEXTFLOW will run them according to resource allocation 
# which is faster 
# The inputs are place holders
# The outputs are what to name or place the outputs
# The Script does the work referencing input as a variable ($)



// Nextflow is best used within a Docker container....

// The output for Everything you run is stored in the "work" directory
Nextflow hello-world.nf
Nextflow hello-world.nf --params

// The work direct ory also contains various logs such as an error log ie .command.err
// or .command.sh which contains the actual script that was run converted into BASH
!/bin/bash -ue
echo 'Hello World!'



// the NEXTFLOW file (ie *.nf) will look a but different and contains  processes and a workflows
// the """" is like typeing script: in YAML you can also just type "script:" but the it needs to come 
// as the last step in the process. if you use """" then it can go anywhere
// there has to be a workflow section that states each process as a fuction 
// Channels like other variables can be used as an input
// Script parameters
params.my_parameter1 = "default parameter-1"
params.my_parameter2 = "default parameter-2"


process sayHello {
// declaring inputs allow usage in the output section
// val indicates the kind of variable it is
// declares a a variable of type value which is now available for refernece
    input:
        val greeting

// path  indicates the kind of variables it is
    output: 
        stdout // just print to screen
        //writes to a file named output.txt 
        path 'output.txt' 
        // file name is entered a parameter
        path params.output.txt 

// we can print to screen, or write to file. 
// use the $ to acesss greeting  the  variables as they comine from the workflow
// params allows the nextflow execution to accept a parameter
    script:
    echo 'Hello World!' 
    echo 'Hello World!' > '$params.output.txt' 
    echo '$greeting'   

}

//  processes to be exeuted go in workflow 
workflow {
    // creates a channel called greeting_ch now we can use it as an input
    greeting_ch =  Channel.of('Hello world!')
    // allows us to enter a greeting as a parmeter on exection
    greeting_ch1 =  Channel.of(params.greeting)
    // create a channel for inputs
    greeting_ch2 = Channel.of('Hello','Bonjour','Holà')
    // create a channel for inputs from a file. The params allows the nextflow execution to accept a parameter
    greeting_ch3 = Channel.fromPath(params.input_file).splitText() { it.trim() }

    // calls the say Hello Process
    sayHello()
    // channel declartions are used as the input called greeting when the process is called
    sayHello(greeting_ch)
}








// In this process we 
// Use a text replace utility to convert the greeting to uppercase
// Script parameters
params.input_file = "/my/input/path"

// declares a a variable of type path which is now available for refernece
process convertToUpper {
    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    script:
    cat $input_file | tr '[a-z]' '[A-Z]' > UPPER-${input_file}

}

//in this way we can nest process the ouput from say hello
// is passed into the Convert to Upper
//sayHello.out creates a file that our process will call input file
workflow {
    convertToUpper(sayHello.out)
}









################################## THE  GATK TOOKIT CLI ######################################
// download the proper image
// always use a specific version of samtols
docker pull quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1

// spin the image up once the volume is mounted you can navigate inside the container
// and and outside otherwise you'll be trapped inside 
// you should see $ sh-5.2# 
docker run -it -v ./data:/data quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1


// once we're in the container run the tools and check whats there
samtools index data/bam/reads_mother.bam
ls data/bam/


// next unzip the reference genome
tar -zxvf data/ref.tar.gz -C data/

// leave the  quay.io container and pull and spin up a container for GATK
//  its better to have containers for each tool for adaptibility to version
// don't worry you'll still have access to what the earlier container created
docker pull docker.io/broadinstitute/gatk:4.5.0.0
docker run -it -v ./data:/data docker.io/broadinstitute/gatk:4.5.0.0


gatk HaplotypeCaller \
        /// geinome to index on
        -R /data/ref/ref.fasta \ 
        /// sequences to align
        -I /data/bam/reads_mother.bam \  
        /// give a name to the output file 
        -O reads_mother.g.vcf \   
        -L /data/intervals.list \
        /// variant callin type
        -ERC GVCF                       

// Here we can examine our result here he just mapped to a single chromosome
// reltively small area
cat reads_mother.g.vcf

// RUN  GATK USING MULTIPLE PARMETERS 
GATK_HAPLOTYPECALLER(
    reads_ch,
    SAMTOOLS_INDEX.out,
    params.genome_reference,
    params.genome_reference_index,
    params.genome_reference_dict,
    params.calling_intervals
)












################################ WE CAN ALSO DIRECT NEXTFLOW TO RUN THE GATK TOOLKIT ######

// initiliazing Pipeline parameters allows them to be used in NEXTFLOW execution
params.baseDir = "/workspace/gitpod/hello-nextflow"
// set base directory
$baseDir = params.baseDir
// set where reads are located 
params.reads_bam = "${baseDir}/data/bam/reads_mother.bam"
// Here for one of the params we can create a  list of lists
// in this case in the channel creation below reads_ch will be nested channel
// this allows us to work in batches
params.reads_bam = [
    "${baseDir}/data/bam/reads_mother.bam", // list of mother files
    "${baseDir}/data/bam/reads_father.bam",  // list of father files
    "${baseDir}/data/bam/reads_son.bam"         // list of child files
]

// Generate BAM index file
process SAMTOOLS_INDEX {
    // next flow to spin up a docker container
    container 'quay.io/biocontainers/samtools:1.19.2--h50ea8bc_1'
    // declares a a variable of type path which is now available
    input:
        path input_bam
    output:
        path "${input_bam}.bai"
        // sometimes the output is a list of lists
        tuple path(input_bam), path("${input_bam}.bai") ///????
    script:
    samtools index '$input_bam'

}

workflow {
    // Create input channel (single file via CLI parameter)
    reads_ch = Channel.from(params.reads_bam)
    // feed our channel into the SAMTOOLS_INDEX process each read 
    // will be an input_bam
    SAMTOOLS_INDEX(reads_ch)
}


// we can know run our nextflow file
nextflow run hello-gatk.nf





