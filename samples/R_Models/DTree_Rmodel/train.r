hmeq <- read.csv("./data/hmeq_train.csv")

hmeq <- hmeq |>
  dplyr::select(-VALUE, -MORTDUE, -LOAN) |>
  dplyr::mutate_at(c("BAD", "REASON", "JOB"), as.factor)

hmeq[hmeq == ""] <- NA
hmeq <- na.omit(hmeq) 

partition <- sample(c(1,2,3), replace = TRUE, prob = c(0.7, 0.2, 0.1), size = nrow(hmeq))

library(rpart)
model <- rpart(formula = BAD ~ ., 
               data = hmeq[partition == 1,], 
               method = "class")
               
saveRDS(model, "dtree.rds", version = 2)


