################ WE CAN ALSO DIRECT NEXTFLOW TO RUN THE GATK TOOLKIT USING MODULES ######

// To make modules its a good idea to move all parameters into a config file
// This way your code doesnt need to change as much 
// modules can leverage the concept of testing


cd /workspace/gitpod/hello-nextflow
tar -zxvf data/ref.tar.gz -C data/


docker.enabled = true
docker.fixOwnerhsip = true


// nextflow like to check if a command was run already by 
// checking the containers hashes etc and resumes
nextflow run hello-modules.nf


// Pipeline parameters
// Execution environment setup
params.baseDir = "/workspace/gitpod/hello-nextflow"
$baseDir = params.baseDir

// Primary input (samplesheet in CSV format with ID and file path, one sample per line)
params.reads_bam = "${baseDir}/data/samplesheet.csv"
// Accessory files
params.genome_reference = "${baseDir}/data/ref/ref.fasta"
params.genome_reference_index = "${baseDir}/data/ref/ref.fasta.fai"
params.genome_reference_dict = "${baseDir}/data/ref/ref.dict"
params.calling_intervals = "${baseDir}/data/intervals.list"

// Base name for final output file
params.cohort_name = "family_trio"


// make directory to house the code
mkdir -p modules/local/samtools/index

// create a file with that directory
touch modules/local/samtools/index/main.nf






// Moving the process code into this file so that input: output: and 
// script: won't need to be re typed and will be  called by the Include statment
############################## main.nf #########################################
process sayHello {
    input:
        val greeting

    output: 
        stdout // just print to screen
        path 'output.txt' 
        path params.output.txt 

    script:
        echo 'Hello World!' 
        echo 'Hello World!' > '$params.output.txt' 
        echo '$greeting'   
}

process SAMTOOLS_INDEX {...}

###############################################################################

// an include  statment comes before the workflow{} declaration so that the process 
// come from the file main.nf. 
include { SAMTOOLS_INDEX } from './modules/local/samtools/index/main.nf'

//  processes to be exeuted now referenced in main.nf
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
