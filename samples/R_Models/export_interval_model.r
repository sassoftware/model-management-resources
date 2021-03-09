# title: "export_interval_model.r"
# author: "SAS Institute"
# date: "July 16, 2020" - Initial version

# Control to print all 13 digits
options(digits = 13)

# Load the necessary libraries
library(jsonlite)
library(zip)

compute_interval_model_metric <- function
(
    target,                   # Vector that contains values of target variable
    predValue                 # Vector that contains predicted values of target variable
)
{
    nobs = length(target)

    # Sum of corrected total (SST)
    mean_target = mean(target)
    sst <- sum((target - mean_target)^2)

    # Sum of Squares Error (SSE)
    sse <- sum((predValue - target)^2)

    # Mean Square Error (MSE)
    mse <- sse / nobs

    # Root Mean Square Error (RMSE)
    rmse <- ifelse(mse > 0.0, sqrt(mse), 0.0)

    # R-Square (RSQUARE)
    rsquare <- cor(target, predValue)
    rsquare <- rsquare * rsquare

    # Mean Absolute Error (MAE)
    mae <- mean(abs(predValue - target))

    output_list = list("MAE" = mae, "MSE" = mse, "NOBS" = nobs, "RMSE" = rmse, "RSQUARE" = rsquare, "SSE" = sse, "SST" = sst)
    return(output_list)

}   # End of function compute_interval_model_metric

export_interval_model <- function
(
    targetVar,                # Name of the target variable
    intervalVars,             # List of names of interval predictors
    nominalVars,              # List of names of nominal predictors
    nominalVarsLength,        # List of lengths of nominal predictors
    typeOfColumn,             # List of types of target variable and predictors
    targetValue,              # Vector that contains values of target variable
    predValue,                # Vector that contains predicted values of target variable
    algorithmCode,            # Code the algorthm used (1 = Logistic regression)
    modelObject,              # R model object
    analysisFolder,           # Full folder path of the analysis folder
    analysisPrefix,           # File name prefix of all the analysis files
    jsonFolder,               # Full folder path of the JSON destination folder
    analysisName,             # A string used as the name of the analysis
    analysisDescription,      # A string used for describing the analysis
    qDebug = 'N'              # Show the debugging output ('Y' or 'N')
)
{
    # Process some arguments
    qDebug = toupper(qDebug)

    # Initialize
    if (algorithmCode == 1) algorithm = 'Logistic regression'
    else if (algorithmCode == 2) algorithm = 'Discriminant'
    else if (algorithmCode == 3) algorithm = 'Decision tree'
    else if (algorithmCode == 4) algorithm = 'Gradient boosting'
    else if (algorithmCode == 5) algorithm = 'Generalized linear model'
    else algorithm = ''

    # Calculate the goodness-of-fit metrics
    output_list <- compute_interval_model_metric(targetValue, predValue)
    m_mae <- output_list$MAE
    m_mse <- output_list$MSE
    nObservation <- output_list$NOBS
    m_rmse <- output_list$RMSE
    m_rsquare <- output_list$RSQUARE
    m_sse <- output_list$SSE
    m_sst <- output_list$SST

    if (qDebug == 'Y')
    {
        # Display the model goodness-of-fit information
        print('=== Model Goodness-of-Fit Metrics ===')
        print(paste('          Mean Absolute Error =', m_mae))
        print(paste('            Mean Square Error =', m_mse))
        print(paste('       Root Mean Square Error =', m_rmse))
        print(paste('                     R-Square =', m_rsquare))
        print(paste('          Sum of Square Error =', m_sse))
        print(paste('Sum of Corrected Square Total =', m_sst))
    }

    # Generate all the necessary files for importing this model into Model Manager

    # 1. RDS file for storing the R model object
    saveRDS(modelObject, file = paste(jsonFolder, analysisPrefix, '_r.rds', sep = ''))

    # 2. The fileMetadata.json file
    fileMetadata <- data.frame(
        'role' = c('inputVariables', 'outputVariables', 'trainResource', 'score', 'scoreResource', 'train'),
        'name' = c('inputVar.json', 'outputVar.json', 'dmcas_fitstat.json',
                 paste(analysisPrefix, '_r_score.r', sep = ''),
                 paste(analysisPrefix, '_r.rds', sep = ''),
                 paste(analysisPrefix, '_train.r', sep = '')))

    # The write_json() function is part of the jsonlite library
    write_json(fileMetadata, path = paste(jsonFolder, 'fileMetadata.json', sep = ''), pretty = TRUE, auto_unbox = TRUE)

    # 3. The ModelProperties.json file
    ModelProperties <- list('name' = analysisName,
                            'description' = analysisDescription,
                            'function' = 'prediction',
                            'scoreCodeType' = 'r',
                            'trainTable' = ' ',
                            'trainCodeType' = 'r',
                            'algorithm' = algorithm,
                            'targetVariable' = targetVar,
                            'targetLevel' = 'INTERVAL',
                            'predictionVariable' = 'EM_PREDICTION',
                            'modeler' = Sys.info()['user'],
                            'tool' = R.version$language,
                            'toolVersion' = R.version.string)

    write_json(ModelProperties, path = paste(jsonFolder, 'ModelProperties.json', sep = ''), pretty = TRUE, auto_unbox = TRUE)

    # 4. The inputVar.json file
    inputVar <- data.frame('name' = character(), 'length' = integer(), 'type' = character(), 'level' = character())

    # Nominal predictors
    for (var in nominalVars)
    {
        typeOfVar <- typeOfColumn[var,]
        if (typeOfVar == 'character') vType = 'string'
        else if (typeOfVar == 'double' | typeOfVar == 'integer') vType = 'decimal'
        else vType = ''
        vList <- data.frame('name' = var, 'length' = nominalVarsLength[var,], 'type' = vType, 'level' = 'nominal')
        inputVar <- rbind(inputVar, vList, stringsAsFactors = FALSE)
    }

    # Interval predictors
    for (var in intervalVars)
    {
        typeOfVar <- typeOfColumn[var,]
        if (typeOfVar == 'double' | typeOfVar == 'integer') vType = 'decimal'
        else vType = ''
        vList <- data.frame('name' = var, 'length' = 8, 'type' = vType, 'level' = 'interval')
        inputVar <- rbind(inputVar, vList, stringsAsFactors = FALSE)
    }
    write_json(inputVar, path = paste(jsonFolder, 'inputVar.json', sep = ''), pretty = TRUE, auto_unbox = TRUE)

    # 5. The outputVar.json file
    outputVar <- data.frame(
        'name' = c('EM_PREDICTION', 'R_FUNC_ELAPSED'),
        'length' = c(8,8),
        'type' = c('decimal','decimal'),
        'level' = c('interval','interval'))

    write_json(outputVar, path = paste(jsonFolder, 'outputVar.json', sep = ''), pretty = TRUE, auto_unbox = TRUE)

    # 6. The dmcas_fitstat.json file
    dict_DataRole <- list('parameter' = '_DataRole_', 'type' = 'char', 'label' = 'Data Role',
                          'length'= 10, 'order' = 1, 'values' = array(c('_DataRole_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd <- list('parameter' = '_PartInd_', 'type' = 'num', 'label' = 'Partition Indicator',
                         'length' = 8, 'order' = 2, 'values' = array(c('_PartInd_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd__f <- list('parameter' = '_PartInd__f', 'type' = 'char', 'label' = 'Formatted Partition',
                            'length' = 12, 'order' = 3, 'values' = array(c('_PartInd__f'), dim=(1)), 'preformatted' = FALSE)

    dict_NObs <- list('parameter' = '_NObs_', 'type' = 'num', 'label' = 'Sum of Frequencies',
                      'length' = 8, 'order' = 4, 'values' = array(c('_NObs_'), dim=(1)), 'preformatted' = FALSE)

    dict_ASE <- list('parameter'= '_ASE_', 'type'= 'num', 'label'= 'Average Squared Error',
                     'length'= 8, 'order'= 5, 'values'= array(c('_ASE_'), dim=(1)), 'preformatted' = FALSE)

    dict_DIV <- list('parameter'= '_DIV_', 'type'= 'num', 'label'= 'Divisor for ASE',
                     'length'= 8, 'order'= 6, 'values'= array(c('_DIV_'), dim=(1)), 'preformatted' = FALSE)

    dict_RASE <- list('parameter'= '_RASE_', 'type'= 'num', 'label'= 'Root Average Squared Error',
                      'length'= 8, 'order'= 7, 'values'= array(c('_RASE_'), dim=(1)), 'preformatted' = FALSE)

    parameterMap <- list('_DataRole_'= dict_DataRole, '_PartInd_'= dict_PartInd, '_PartInd__f'=  dict_PartInd__f,
                         '_NObs_' = dict_NObs, '_ASE_' = dict_ASE, '_DIV_' = dict_DIV, '_RASE_' = dict_RASE)

    fitStats <- list('_DataRole_' = unbox('TRAIN'),
                     '_PartInd_' = unbox(1),
                     '_PartInd__f' = unbox('           1'),
                     '_DIV_' = unbox(nObservation),
                     '_MAE_' = unbox(m_mae),
                     '_MSE_' = unbox(m_mse),
                     '_NObs_' = unbox(nObservation),
                     '_RMSE_' = unbox(m_rmse),
                     '_RSQUARE_' = unbox(m_rsquare),
                     '_SSE_' = unbox(m_sse),
                     '_SST_' = unbox(m_sst))

    dmcas_fitstat <- list('name' = 'dmcas_fitstat',
                          'revision' = 0,
                          'order' = 0,
                          'parameterMap' = parameterMap,
                          'data' =  array(list(list('dataMap' = fitStats, 'rowNumber' = unbox(1))), dim = c(1)),
                          'version' = 1,
                          'xInteger' = FALSE,
                          'yInteger' = FALSE)

    write_json(dmcas_fitstat, path = paste(jsonFolder, 'dmcas_fitstat.json', sep = ''), pretty = TRUE, auto_unbox = TRUE, digits = 13)

    # Put all the files in the jsonFolder to the ZIP package
    files2zip <- array(c(paste(jsonFolder, 'fileMetadata.json', sep = ''),
                         paste(jsonFolder, 'ModelProperties.json', sep = ''),
                         paste(jsonFolder, 'inputVar.json', sep = ''),
                         paste(jsonFolder, 'outputVar.json', sep = ''),
                         paste(jsonFolder, 'dmcas_fitstat.json', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_train.r', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_r_score.r', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_r.rds', sep = '')), dim = c(8))

    zipr(zipfile = paste(jsonFolder, analysisPrefix, '_r.zip', sep = ''), files = files2zip, recurse = FALSE, include_directories = FALSE)

}   # end of function export_binary_modell
