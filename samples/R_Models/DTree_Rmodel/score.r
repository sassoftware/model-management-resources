library("stats")

scoreFunction <- function(REASON, JOB, YOJ, DEROG, DELINQ, CLAGE, NINQ, CLNO, DEBTINC) {
  # Output: EM_CLASSIFICATION, EM_EVENTPROBABILITY
  
  # Check if the model is already loaded, if not, load it
  if (!exists("sasctlRmodel")) {
    sasctlRmodel <<- readRDS(file = file.path(rdsPath, "dtree.rds"))
  }
  
  REASON <- gsub(" ", "", REASON, fixed = TRUE)
  JOB <- gsub(" ", "", JOB, fixed = TRUE)
  
  # Create a data frame with the input variables
  data <- data.frame(
    REASON = as.factor(REASON),
    JOB = as.factor(JOB),
    YOJ = YOJ,
    DEROG = DEROG,
    DELINQ = DELINQ,
    CLAGE = CLAGE,
    NINQ = NINQ,
    CLNO = CLNO,
    DEBTINC = DEBTINC
  )
  
  # Make predictions using the loaded model
  pred <- predict(sasctlRmodel, newdata = data, type = "prob")
  EM_EVENTPROBABILITY <- pred[, "1"]
  EM_CLASSIFICATION <- ifelse(EM_EVENTPROBABILITY >= 0.5, 1, 0)
  
  # Create the output data frame
  output_df <- data.frame(
    EM_CLASSIFICATION = EM_CLASSIFICATION,
    EM_EVENTPROBABILITY = EM_EVENTPROBABILITY
  )
  
  return(output_df)
}



