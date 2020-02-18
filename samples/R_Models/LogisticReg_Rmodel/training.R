# Copyright (c) 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

inputdata <- read.csv(file="hmeq_train.csv", header=TRUE, sep=",")

attach(inputdata)
# -----------------------------------------------
# FIT THE LOGISTIC MODEL
# -----------------------------------------------
reg<- glm(BAD ~ VALUE + factor(REASON) + factor(JOB) + DEROG + CLAGE + NINQ + CLNO , family=binomial)

# -----------------------------------------------
# SAVE THE OUTPUT PARAMETER ESTIMATE TO LOCAL FILE OUTMODEL.RDA
# -----------------------------------------------
save(reg, file="reg.rda")
