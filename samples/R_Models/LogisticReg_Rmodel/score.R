# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

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
# SCORE THE MODEL
# -----------------------------------------------
score<- predict(get(model), type="response", newdata=inputdata)
# simple round up
P_BAD1<-score
P_BAD0<-1-P_BAD1

# -----------------------------------------------
# MERGING PREDICTED VALUE WITH MODEL INPUT VARIABLES
# -----------------------------------------------
mm_outds <- cbind(inputdata, P_BAD0, P_BAD1)

#mm_outds <- cbind(P_BAD0, P_BAD1)
write.csv(mm_outds, file = outputfile, row.names=F)

