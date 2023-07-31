#!/usr/bin/env nextflow 

# The shebang here instructs which interpretor to use similar to bash  and where to find it



 
#greeting is now a parameter set to value hello world
params.greeting = 'Hello world!'


  0 apr 
# now we have a channel called greetin_ch that holds the value of what params.greeting was set to
# channels are used as inputs in our processes.I think they can even be defined within a process
greeting_ch = Channel.of(params.greeting)





#process have 3 sections. they are input output and script
#the inputs can be declared as values(val) paths(path) of files(file) it 
# the output sets the variable for what comes out in this case a path called chunk_
# here we print whatever is in the variable x at the time ..send it to the split function which has some options
# causing to 6 letter chunks. each will be saved to a file chunk_aa and chunk_ab
process SPLITLETTERS{

    input:
    val x

    output:
    path 'chunk_*'


    script:
    """
    printf $x | spliit -b 6 - chunk_

    """

}
    
  
process CONVERTTOUPPER {

  input:
  path y

  output:
  stdout 


  script:
  """
  cat $y | tr '[a-z]'  '[A-Z']

  """


}



# not only are channels defined to be used in processes but the processes themselves can be used
# to create a channel to be used in another process 
# flatten and view are nextflow functions we can call to format and view our

workflow{

 letters_ch = SPLITLETTERS(greetings_ch) 
 results_ch = CONVERTTOUPPER(letters_ch.flatten())
 resultch.view{it}



# to execute this we would type nextflow run hello.nf
