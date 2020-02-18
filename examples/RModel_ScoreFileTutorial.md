# How to Fit Your Scoring Script for R Model Containerization

## Overview
The Web services in the container store the input CSV file and pass the input file name to your scoring script. Your scoring script must follow a specific pattern. 

In this tutorial, I explain the pattern that you must follow in your scoring script.

## Search Order
The Web services in the container first start searching for the scoring script that is defined in the fileMetadata.json file, if it exists.

The fileMetadata.json file is created by the Model Repository API when the model is downloaded from the common model repository. 

You can use the SAS Model Manager or SAS Open Model Manager web application to set the file role for the scoring script to "Score code". This can be done by selecting the scoring script file on the **Files** tab of a model object and editing the file properties. For more information, see [Assign Model File Roles](https://documentation.sas.com/?cdcId=openmmcdc&cdcVersion=1.2&docsetId=openmmug&docsetTarget=n026ttfq4xcn5an19dpfo4jcyuqz.htm&locale=en#n1k0tfrt0d1dqtn1gvw5huqz7gpb) in the _SAS Open Model Manager 1.2: User's Guide_.

If, the file role for the scoring script is not set as "Score code", the Web services searches for the first script whose file name ends with 'score.R' for an R model.
    
## Commands
The Web services call your scoring script using the following formats. 

Note: The log file records all of the stdout and stderr outputs from the scoring script during execution.


### R
```
Rscript <score filename> [model filename] <input csv filename> <output csv filename> >> <log filename> 2>&1
```

## Samples
Based on above description, the pattern of the scoring script must accept two parameters for input and output CSV files. 

In the next section there is a R scoring script sample with the pattern.

### R
You can copy part of the following sample script and add support for argument parsing, and then save your result in your R scoring script.

```
# Default R score code that helps score the R model with RDA file.
# You must write your own score file if your R model does not have an RDA model file.

# If the RDA model file has not been specified in command-line arguments, the script
# looks for the first RDA file in the current directory, and the script quits if the file is not found.

args = commandArgs(trailingOnly=TRUE)

if (length(args)<2) {
  stop("Rscript score.R [model file] <inputfile> <outputfile>.n", call.=FALSE)
} else if (length(args)<3) {
  modelfile = ''
  inputfile = args[1]
  outputfile = args[2]
} else {
  modelfile = args[1]
  inputfile = args[2]
  outputfile = args[3]
}

inputdata <- read.csv(file=inputfile, header=TRUE, sep=",")

if (modelfile == '') {
  files <- list.files(pattern = "\\.rda$")

  if(length(files) == 0) {
     print("not found rda file in the directory!")
     stop()
  }

  modelfile<-files[[1]]
}

model<-load(modelfile)
# -----------------------------------------------
# Score the Model
# -----------------------------------------------
# The value of the type depends on which algorithm is being used in the model
score<- predict(get(model), type="vector", newdata=inputdata)

# -----------------------------------------------
# MERGING PREDICTED VALUE WITH MODEL INPUT VARIABLES
# -----------------------------------------------
mm_outds <- cbind(inputdata, score)

write.csv(mm_outds, file = outputfile, row.names=F)

```


## License

This project is licensed under the [Apache 2.0 License](../LICENSE).

