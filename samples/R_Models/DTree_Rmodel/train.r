# Copyright (C) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

inputdata <- read.csv(file="hmeq_train.csv", header=TRUE, sep=",")

for(i in 1:ncol(inputdata)){
  if(i!= 5 && i!=6){
    inputdata[is.na(inputdata[,i]), i] <- mean(inputdata[,i], na.rm = TRUE)
  }
}

library(rpart)
# -----------------------------------------------
# FIT THE LOGISTIC MODEL
# -----------------------------------------------
dtree<- rpart(BAD ~ MORTDUE + LOAN + VALUE + factor(REASON) + factor(JOB) + DEROG + CLAGE + NINQ + DELINQ + DEBTINC, data = inputdata)

# -----------------------------------------------
# SAVE THE OUTPUT PARAMETER ESTIMATE TO LOCAL FILE OUTMODEL.RDA
# -----------------------------------------------
save(dtree, file="dtree.rda")