#!/usr/bin/sh nextflow 

# The shebang here instructs which interpretor to use 
# similar to bash  and where to find it




#NEXTFLOW basics 
########################FILES##################################
file(path_to_file)

list_of_files= file(/path/to/myfiles/*.fa, hidden: true)
               files(/path/to/myfiles/*.fa, hidden: true)

allLines = my_file.readLines()' #returns list containing all lines
for( line : allLines ){
print line
}

#same thing as above...
file(path to file)
    .readLines()
    .each{println}


#reads in one line at a time and prints it out 
count = 1
myFile.eachline{str ->
    print "line ${count} is  ${str}
     count = count + 1
}


my_file.moveTo(target_directory_to_relocate_to)
my_file.renameTo(new_name)
my_file.delete()
.getName()
.getBAseName()
.getExtension()
.size()
.lastModified()
.exist()
.isEmpty()
,Countlines()
.countFasta()
.countFastQ()
my_file.append('text you want to add')
my_file <<  'also adds a line'







########################VARIABLES#############################
println "Hello world"  # prints what is in quotes

x = 1
println x


x = new java.util.Date() #set a variable to the output of a function
println x

x = [1, 2, 3, 4, 5, 6] #brackets are used to initiate list

x[0] # with out an equals signs brackets are used tp subset

x.size()  #functions can be called similar to python
println x.list()

(a,b,c) = [10,20, 'foo'] #you can intialize several at once



x.view() # to see the variable

###############################MAPS##############################


my_map =  ["jabbar":205,"James":215,"Dan":175:,"Phil":180] #similar to dictionarys is python

println my_map["James"]
println scores.James

my_map["New_name"] =  300 # adds or modifys the map

2_maps = map1  + ["Preston": 200,"Connor":210,"Stephen": 211] #maps can be bound  together



#the use of closures in Nextflow indicates a function of some kind that can be passed
#to function as a argument 

square = {it * it} #it is now an argument
println square(9) #gives us 81

#square tho a function itself can be passed to other functions
[1,2,3,4,5].collect()

[1,2,3,4,5].collect(square) #the collect function like and lapply in R
["Jabbar":1,"James":2,"Dan":"Phil","Preston":4,"Connor":5].each(println) #allows to lapply a fucntion to more than one parameter


###################################REGEX######################

assert 'pattern_1' ~= 'pattern_2' // return TRUE   #look for any match
assert 'pattern_1' ==~ 'pattern_2' // return FALSE #look for exact match

.replaceFirst(match_sought,"replacment") #replace first occurance
.replaceALL(match_sought,"replacements") #repalce all occurances

wordStartWithGR = ~/(?i)\s+Gr\w+/ #define regex pattern

(my_string - wordStartWithGR)  #deduct that pattern from a string








###################################IF STATEMENTS################
#the use of {} is a little diffrent than Bash 


x=Math.random()
if (x<.05){
  println "x is less then"
}
else
{
println "greater value"
}






#2 process that splits text and then converts to upper case

#greeting is now a parameter set to value hello world
params.greeting = 'Hello world!'
 
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
# set incoming variables as/to paths under a variable called y
  input:
  path y 

#output is not assigned a variable but is classified as a stdout type
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


