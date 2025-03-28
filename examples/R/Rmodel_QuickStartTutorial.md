```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Build a Trained R Model for the Quick Start Tutorial

This example walks you through the steps to generate the R model files for the SAS Model Manager Quick Start Tutorial. 
The code is an extension of the r-sasctl README code found [here](https://github.com/sassoftware/r-sasctl). 
It generates a ZIP file that can be imported directly into SAS Model Manager.
The model can then be scored by running a scoring test, which uses the CAS Gateway action set.
It can also be scored by running a publishing validation after the model has been published to a CAS 
publishing destination, or a container publishing destination where the R base image is used to create
an R runtime container.

Note: A trained R sample model can be found here: [DTree_Rmodel](../../samples/R_Models/DTree_Rmodel)

## Set Up

### Install Packages

The developer version or released version of r-sasctl can be used to generate the model registration files. 
Visit the [r-sasctl GitHub page](https://github.com/sassoftware/r-sasctl/releases) for the latest released version.

```{r}
## dev version
remotes::install_git("https://github.com/sassoftware/r-sasctl")
```

```{r}
## released version (0.7.4)
install.packages(c("jsonlite", "httr", "uuid", "furrr", "ROCR", "reshape2", "base64enc", "dplyr", "glue"))

install.packages("https://github.com/sassoftware/r-sasctl/releases/download/0.7.4/r-sasctl_0.7.4.tar.gz", type = "source", repos = NULL)

library("sasctl")
```

## Model Building

### Load and Modify Data

```{r}
hmeq <- read.csv("./data/hmeq_train.csv")
```

```{r}
hmeq <- hmeq |>
  dplyr::select(-VALUE, -MORTDUE, -LOAN) |>
  dplyr::mutate_at(c("BAD", "REASON", "JOB"), as.factor)

hmeq[hmeq == ""] <- NA
hmeq <- na.omit(hmeq) 
```

### Build a Decision Tree Model

```{r}
## Creating train/test/val
partition <- sample(c(1,2,3), replace = TRUE, prob = c(0.7, 0.2, 0.1), size = nrow(hmeq))

## Decision tree 
library(rpart)
model <- rpart(formula = BAD ~ ., 
               data = hmeq[partition == 1,], 
               method = "class")
```

## Generating Model Files

```{r}
## Directory
dir.create("./") # Changes required by user
path <- "" # Changes required by user
```


### Create a Train Code File

```{r}
train_code <- 'hmeq <- read.csv("./") # Changes required by user

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

'

writeLines(train_code, file.path(path, "train.R"))
```

### Create a Score Code File

```{r}
## save model
saveRDS(model, file.path(path, 'dtree.rds'), version = 2)
```

```{r}
score_code <- 'library("stats")

scoreFunction <- function(REASON, JOB, YOJ, DEROG, DELINQ, CLAGE, NINQ, CLNO, DEBTINC) {
  # Output: EM_CLASSIFICATION, EM_EVENTPROBABILITY
  
  # Check if the model is already loaded, if not, load it
  if (!exists("sasctlRmodel")) {
    sasctlRmodel <<- readRDS(file = file.path(pickle_path, "dtree.rds"))
  }
  
  REASON <- gsub(" ", "", REASON, fixed = TRUE)
  JOB <- gsub(" ", "", JOB, fixed = TRUE)
  
  # Create a data frame with the input variables
  data <- data.frame(
    REASON = REASON,
    JOB = JOB,
    YOJ = YOJ,
    DEROG = DEROG,
    DELINQ = DELINQ,
    CLAGE = CLAGE,
    NINQ = NINQ,
    CLNO = CLNO,
    DEBTINC = DEBTINC
  )
  
  # Make predictions using the loaded model
  pred <- predict(sasctlRmodel, newdata = data, type = "prob", na.action = na.omit)
  EM_EVENTPROBABILITY <- pred[, "1"]
  EM_CLASSIFICATION <- ifelse(EM_EVENTPROBABILITY >= 0.5, 1, 0)
  
  # Create the output data frame
  output_df <- data.frame(
    EM_CLASSIFICATION = EM_CLASSIFICATION,
    EM_EVENTPROBABILITY = EM_EVENTPROBABILITY
  )
  
  return(output_df)
}
'
writeLines(score_code, file.path(path, "score.R"))
```

### Create Scored Data

```{r}
## Running the generated scoring code for testing
codeExpression <- str2expression(score_code)
eval(codeExpression)

pickle_path <- path

result <- scoreFunction(REASON = hmeq[, 'REASON'],
                        JOB = hmeq[, 'JOB'],
                        YOJ = hmeq[, 'YOJ'],
                        DEROG = hmeq[, 'DEROG'],
                        DELINQ = hmeq[, 'DELINQ'],
                        CLAGE = hmeq[, 'CLAGE'],
                        NINQ = hmeq[, 'NINQ'],
                        CLNO = hmeq[, 'CLNO'],
                        DEBTINC = hmeq[, 'DEBTINC'])

scoreddf <- as.data.frame(result)
scoreddf$Actual <- as.numeric(hmeq$BAD) - 1
scoreddf$partition <- partition
```

### Generate Model Registration Files 

```{r}
### diagnostics requires the true Target column name defined in "targetName"
### and the predicted probability column name defined in "targetPredicted"

diags <- diagnosticsJson(validadedf = scoreddf[scoreddf$partition == 3,],
                         traindf = scoreddf[scoreddf$partition == 1,],
                         testdf = scoreddf[scoreddf$partition == 2,],
                         targetEventValue = 1,
                         targetName = "Actual",
                         targetPredicted = "EM_EVENTPROBABILITY",
                         path = path)

## writing other files
write_in_out_json(hmeq[,-1], input = TRUE, path = path)

write_in_out_json(dplyr::select(scoreddf, c(-Actual, -partition)), input = FALSE, path = path)

write_fileMetadata_json(scoreCodeName = "score.R",
                        scoreResource = "dtree.rds",
                        additionalFilesNames = c("train.R"),
                        additionalFilesRoles = c("train"),
                        path = path)

write_ModelProperties_json(modelName = "dtree",
                           modelFunction = "Classification",
                           trainTable = "hmeq_train",
                           algorithm = "Decision Tree",
                           numTargetCategories = 2,
                           targetEvent = "1",
                           targetVariable = "BAD",
                           eventProbVar = "P_BAD1",
                           modeler = "sasdemo",
                           path = path)
```


### Create the Model ZIP File

```{r}
files_to_zip <- list.files(path, "*.json|*.R|*.rds", full.names = T)
zip(file.path(path, "QS_DTree_RModel.zip"), 
    files = files_to_zip)
```
