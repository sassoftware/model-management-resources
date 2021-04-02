# title: fleet_classtree_train.r
# author: SAS Institute
# date: May 7, 2020

# Control to print all 13 digits
options(digits = 13)

# Load the necessary libraries
library(rpart)
library(rpart.plot)

# Specify location of the analysis folder
analysisFolder = 'C:\\MyJob\\Projects\\ModelManager\\Test\\Truck\\'
analysisPrefix = 'fleet_classtree'

# Specify location of the JSON folder
jsonFolder = 'C:\\MyJob\\Projects\\ModelManager\\Test\\Truck\\ClassTree\\R\\'

# Specify location of the custom source folder
sourceFolder = 'C:\\Users\\minlam\\Documents\\Research\\R\\'

# Bring in custom codes for exporting model
source(paste(sourceFolder, 'export_binary_model.r', sep = ''))

# Read the CSV data
inputData <- read.table(paste(analysisFolder, 'Truck_Train.csv', sep = ''), header = TRUE, sep = ',')

# Specify the target variables, the nominal predictors, and the interval predictors
targetVar <- 'Maintenance_flag'
intervalVars <- c('Speed_sensor', 'Vibration', 'Engine_Load', 'Coolant_Temp', 'Intake_Pressure', 'Engine_RPM', 'Speed_OBD',
                  'Intake_Air', 'Flow_Rate', 'Throttle_Pos', 'Voltage', 'Ambient', 'Accel', 'Engine_Oil_Temp', 'Speed_GPS',
                  'GPS_Longitude', 'GPS_Latitude', 'GPS_Bearing', 'GPS_Altitude', 'Turbo_Boost', 'Trip_Distance', 'Litres_Per_km',
                  'Accel_Ssor_Total', 'CO2', 'Trip_Time')

myvars <- c(targetVar, intervalVars)

# Threshold for the misclassification error
threshPredProb <- mean(inputData[[targetVar]], na.rm = TRUE)
print(paste('Observed Probability that ', targetVar, '= 1 is', threshPredProb))

# Remove all observations where the target variable is missing
trainData <- na.omit(inputData)

# Get ready for training the classification tree model.
# 1. Get threshold for the misclassification error

# Specify target as a factor
trainData[[targetVar]] <- as.factor(trainData[[targetVar]])
print(paste('Categories of', targetVar))
print(levels(trainData[[targetVar]]))

# A classification tree, do not carry competitors along, no surrogate, no cross-validation
# split if more than 50 observations, maximum depth is 10
myFormula <- paste(noquote(targetVar), '~')
qNotFirst = 0
for (col in c(intervalVars))
{
    if (qNotFirst == 1)
    {
        sepChar = ' + '
    }
    else
    {
        sepChar = ' '
        qNotFirst = 1
    }
    myFormula <- paste(myFormula, noquote(col), sep = sepChar)
}
print(myFormula)

myClassTree <- rpart(formula = myFormula, method = 'class', data = trainData, na.action = na.omit,
                     control = rpart.control(maxcompete = 0, maxsurrogate = 0, xval = 0,
                                             minsplit = 25, maxdepth = 10))

# Display the tree diagram
rpart.plot(myClassTree)
rpart.rules(myClassTree)

# See the model fit summary
print(summary(myClassTree))

# Calculate the prediction and save then to an external CSV file

# See the Misclassification Rate of the training data
fitted.prob <- predict(myClassTree, newdata = trainData, type = 'prob')
fitted.results <- ifelse(fitted.prob[,2] >= threshPredProb, 1, 0)

# Save the predictions to CSV
write.csv(cbind(trainData, fitted.prob, fitted.results), paste(jsonFolder, analysisPrefix, '_r_pred.csv', sep = ''))

# Types of the columns
typeOfColumn <- as.data.frame(do.call(rbind, lapply(inputData, typeof)))
print(typeOfColumn)

# Invoke this function to generate the zip package
export_binary_model (
    targetVar = targetVar,
    intervalVars = intervalVars,
    nominalVars = NULL,
    nominalVarsLength = NULL,
    typeOfColumn = typeOfColumn,
    targetValue = trainData[[targetVar]],
    eventValue = 1,
    predEventProb = fitted.prob[,2],
    eventProbThreshold = threshPredProb,
    algorithmCode = 3,
    modelObject = myClassTree,
    analysisFolder = analysisFolder,
    analysisPrefix = analysisPrefix,
    jsonFolder = jsonFolder,
    analysisName = 'Truck Fleet Maintenance',
    analysisDescription = 'Classification Tree Model: minsplit = 25, maxdepth = 10',
    lenOutClass = 1,
    qDebug = 'Y')

# THE END
