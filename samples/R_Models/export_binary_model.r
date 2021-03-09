# title: "export_binary_model.r"
# author: "SAS Institute"
# date: "February 25, 2020" - Initial version
# date: "July 2, 2020" - Adapt for R 4.0
# date: "July 30, 2020" - Adapt for new R model import in Model Manager

# Control to print all 13 digits
options(digits = 13)

# Load the necessary libraries
library(jsonlite)
library(ROCR)
library(zip)

compute_binary_model_metric <- function
(
    target,                   # Vector that contains values of target variable
    eventValue,               # Formatted value of target variable that indicates an event
    predEventProb,            # Vector that contains predicted probability that the event will occur
    eventProbThreshold = 0.5  # Threshold for event probability to indicate a success
)
{
    # Aggregate observations by the target values and the predicted probabilities
    aggrProb <- data.frame(table(target, predEventProb, useNA = "no"))

    # Number of observations
    nObs <- sum(aggrProb$Freq)

    # Need to convert the predEventProb column in aggrProb from a factor to a numeric vector
    aggrProb$predEP <- as.numeric(levels(aggrProb$predEventProb))[aggrProb$predEventProb]

    # Extract the predicted event probabilities for the event target
    eAggrProb <- aggrProb[aggrProb$target == eventValue & aggrProb$Freq > 0,]

    # Extract the predicted event probabilities for the non-event target
    neAggrProb <- aggrProb[aggrProb$target != eventValue & aggrProb$Freq > 0,]

    # Calculate the root average square error
    ase <- (sum(eAggrProb$Freq * (1.0 - eAggrProb$predEP)^2) + sum(neAggrProb$Freq * (0.0 - neAggrProb$predEP)^2)) / nObs
    rase <- ifelse(ase > 0.0, sqrt(ase), 0.0)

    # Calculate the misclassification rate
    misClass <- sum(ifelse(eAggrProb$predEP >= eventProbThreshold, 0, eAggrProb$Freq))
    misClass <- misClass + sum(ifelse(neAggrProb$predEP >= eventProbThreshold, eAggrProb$Freq, 0))
    misClass <- misClass / nObs

    # Calculate the number of concordant, discordant, and tied pairs
    nConcordant <- 0
    nDiscordant <- 0
    nTied <- 0

    # Loop over the predicted event probabilities from the Event table
    nRowEventTable = nrow(eAggrProb)
    for (i in 1:nRowEventTable) {
        eProb <- eAggrProb$predEP[i]
        eFreq <- eAggrProb$Freq[i]
        nConcordant <- nConcordant + sum(ifelse(neAggrProb$predEP < eProb, (eFreq * neAggrProb$Freq), 0))
        nDiscordant <- nDiscordant + sum(ifelse(neAggrProb$predEP > eProb, (eFreq * neAggrProb$Freq), 0))
        nTied <- nTied + sum(ifelse(neAggrProb$predEP == eProb, (eFreq * neAggrProb$Freq), 0))
    }

    output_list = list("NOBS" = nObs, "ASE" = ase, "RASE" = rase, "MCE" = misClass, "nConcordant" = nConcordant, "nDiscordant" = nDiscordant, "nTied" = nTied)
    return(output_list)

}   # End of function compute_binary_model_metric

compute_lift_coordinates <- function (
    DepVar,          # The column that holds the dependent variable's values
    EventValue,      # Value of the dependent variable that indicates an event
    EventPredProb)   # The column that holds the predicted event probability
{
    # Find out the number of observations
    nObs <- length(EventPredProb)
    
    # Get the deciles
    quantileCutOff <- quantile(EventPredProb, probs = seq(0.0, 1.0, by = 0.1))
    nQuantile <- length(quantileCutOff)
    
    quantileIndex <- vector(mode = "numeric", length = nObs)
    for (i in c(1:nObs))
    {
        iQ <- nQuantile
        EPP <- EventPredProb[i]
        for (j in c(1:(nQuantile-1)))
        {
            if (EPP > quantileCutOff[nQuantile-j+1]) iQ <- iQ - 1
        }
        quantileIndex[i] <- iQ
    }

    # Construct the Lift chart table
    countTable = table(quantileIndex, DepVar)
    print(countTable)

    decileN = rowSums(countTable)
    decilePct = 100.0 * (decileN / nObs)
    gainN = countTable[,toString(EventValue)]
    totalNResponse = sum(gainN)
    gainPct = 100.0 * (gainN /totalNResponse)
    responsePct = 100.0 * (gainN / decileN)
    overallResponsePct = 100.0 * (totalNResponse / nObs)
    lift = responsePct / overallResponsePct
    
    LiftCoordinates = cbind(decileN, decilePct, gainN, gainPct, responsePct, lift)

    # Construct the Accumulative Lift chart table
    accCountTable = apply(countTable, 2, cumsum)
    accDecileN = rowSums(accCountTable)
    accDecilePct = 100.0 * (accDecileN / nObs)
    accGainN = accCountTable[,toString(EventValue)]
    accGainPct = 100.0 * (accGainN / totalNResponse)
    accResponsePct = 100.0 * (accGainN / accDecileN)
    accLift = accResponsePct / overallResponsePct

    LiftCoordinates = cbind(decileN, decilePct, gainN, gainPct, responsePct, lift,
                            accDecileN, accDecilePct, accGainN, accGainPct, accResponsePct, accLift)

    return(LiftCoordinates)

}   # End of function compute_lift_coordinates

export_binary_model <- function
(
    targetVar,                # Name of the target variable
    intervalVars,             # List of names of interval predictors
    nominalVars,              # List of names of nominal predictors
    nominalVarsLength,        # List of lengths of nominal predictors
    typeOfColumn,             # List of types of target variable and predictors
    targetValue,              # Vector that contains values of target variable
    eventValue,               # Formatted value of target variable that indicates an event
    predEventProb,            # Vector that contains predicted probability that the event will occur
    eventProbThreshold = 0.5, # Threshold for event probability to indicate a success
    algorithmCode,            # Code the algorthm used (1 = Logistic regression)
    modelObject,              # R model object
    analysisFolder,           # Full folder path of the analysis folder
    analysisPrefix,           # File name prefix of all the analysis files
    jsonFolder,               # Full folder path of the JSON destination folder
    analysisName,             # A string used as the name of the analysis
    analysisDescription,      # A string used for describing the analysis
    lenOutClass = 1,          # Length of the output classification field
    qDebug = 'N'              # Show the debugging output ('Y' or 'N')
)
{
    # Process some arguments
    if (eventProbThreshold < 0.0 | eventProbThreshold > 1.0) eventProbThreshold <- 0.5
    qDebug = toupper(qDebug)

    # Initialize
    if (algorithmCode == 1) algorithm = 'Logistic regression'
    else if (algorithmCode == 2) algorithm = 'Discriminant'
    else if (algorithmCode == 3) algorithm = 'Decision tree'
    else if (algorithmCode == 4) algorithm = 'Gradient boosting'
    else algorithm = ''

    # Calculate the goodness-of-fit metrics
    output_list <- compute_binary_model_metric(targetValue, eventValue, predEventProb, eventProbThreshold)
    nObservation <- output_list$NOBS
    m_ase <- output_list$ASE
    m_rase <- output_list$RASE
    m_mce <- output_list$MCE
    nConcordant <- output_list$nConcordant
    nDiscordant <- output_list$nDiscordant
    nTied <- output_list$nTied
    nPair <- nConcordant + nDiscordant + nTied

    # Calculate the Gini Coefficient metric
    m_gini <- (nConcordant - nDiscordant) / nPair

    # Calculate Area Under Curve metric
    m_auc <- 0.5 + 0.5 * m_gini

    # Calculate the Goodman-Kruskal Gamma metric
    m_gamma <- (nConcordant - nDiscordant) / (nConcordant + nDiscordant)

    # Calculate the kendall's Tau metric
    m_tau_a <- (nConcordant - nDiscordant) / (nObservation * (nObservation - 1.0) / 2.0)

    # Calculate the ROC coordinates (in the ROCR library)
    pr <- prediction(predEventProb, targetValue)
    roc_coordinate <- performance(pr, measure = "tpr", x.measure = "fpr")

    # Calculate Kolmogorov-Smirnov metric
    roc_fpr <- unlist(roc_coordinate@x.values)
    roc_tpr <- unlist(roc_coordinate@y.values)
    roc_cutoff <- unlist(roc_coordinate@alpha.values)
    roc_ncoord <- length(roc_cutoff)

    diff_pr <- roc_tpr - roc_fpr
    i_cutoff <- which.max(diff_pr)
    m_ks <- diff_pr[i_cutoff]
    m_ks_cutoff <- roc_cutoff[i_cutoff]

    # Calculate coordinates for the Lift and the Cumulative Lift charts
    lift_coordinate <- compute_lift_coordinates (targetValue, eventValue, predEventProb)

    if (qDebug == 'Y')
    {
        # Display the model goodness-of-fit information
        print('=== Model Goodness-of-Fit Metrics ===')
        print(paste('    Misclassification Rate =', m_mce))
        print(paste('      Average Square Error =', m_ase))
        print(paste(' Root Average Square Error =', m_rase))
        print(paste('          Gini Coefficient =', m_gini))
        print(paste('          Area Under Curve =', m_auc))
        print(paste('     Goodman-Kruskal Gamma =', m_gamma))
        print(paste('             Kendall tau-a =', m_tau_a))
        print(paste(' Kolmogorov-Smirnov Metric =', m_ks))
        print(paste('Kolmogorov-Smirnov Cut-off =', m_ks_cutoff))

        print(lift_coordinate)
        
        # Draw the ROC curve
        plot(roc_fpr, roc_tpr, type = 'b', main = 'Receiver Operating Characteristics Curve', col = 'blue')
        abline(a = 0, b = 1, col = 'red', lty = 3, lwd = 0.5)
        axis(1, at = seq(0.0, 1.0, 0.1))
        axis(2, at = seq(0.0, 1.0, 0.1))
        grid()

        # Draw the Lift chart
        plot(lift_coordinate[,"accDecilePct"], lift_coordinate[,'lift'], type = 'b', main = 'Lift Chart', xlab = 'Top Decile Percent', ylab = 'Lift', col = 'blue')
        axis(1, at = seq(0.0, 100.0, 10.0))
        grid()

        # Draw the Cumulative Lift chart
        plot(lift_coordinate[,"accDecilePct"], lift_coordinate[,'accLift'], type = 'b', main = 'Cumulative Lift Chart', xlab = 'Top Decile Percent', ylab = 'Cumulative Lift', col = 'blue')
        axis(1, at = seq(0.0, 100.0, 10.0))
        grid()

        # Plot the Kolmogorov-Smirnov chart
        plot(roc_cutoff, roc_tpr, type = 'b', main = 'Kolmogorov-Smirnov Chart', col = 'blue', xlab = 'Cut-off', ylab = 'Positive Rates')
        lines(roc_cutoff, roc_fpr, type = 'b', col = 'red')
        axis(side = 1, at = seq(0.0, 1.0, 0.1))
        axis(side = 2, at = seq(0.0, 1.0, 0.1))
        legend('topright', c('True Positive', 'False Positive'), fill = c('blue', 'red'))
        grid()
    }

    # Generate all the necessary files for importing this model into Model Manager

    # 1. RDS file for storing the R model object
    saveRDS(modelObject, file = paste(jsonFolder, analysisPrefix, '_r.rds', sep = ''))

    # 2. The fileMetadata.json file
    fileMetadata <- data.frame(
        'role' = c('inputVariables', 'outputVariables', 'trainResource', 'trainResource', 'trainResource',
                   'score', 'scoreResource', 'train'),
        'name' = c('inputVar.json', 'outputVar.json', 'dmcas_fitstat.json', 'dmcas_lift.json', 'dmcas_roc.json',
                 paste(analysisPrefix, '_r_score.r', sep = ''),
                 paste(analysisPrefix, '_r.rds', sep = ''),
                 paste(analysisPrefix, '_train.r', sep = '')))

    # The write_json() function is part of the jsonlite library
    write_json(fileMetadata, path = paste(jsonFolder, 'fileMetadata.json', sep = ''), pretty = TRUE, auto_unbox = TRUE)

    # 3. The ModelProperties.json file
    ModelProperties <- list('name' = analysisName,
                            'description' = analysisDescription,
                            'function' = 'classification',
                            'scoreCodeType' = 'r',
                            'trainTable' = ' ',
                            'trainCodeType' = 'r',
                            'algorithm' = algorithm,
                            'targetVariable' = targetVar,
                            'targetEvent' = eventValue,
                            'targetLevel' = 'BINARY',
                            'eventProbVar' = 'EM_EVENTPROBABILITY',
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
        'name' = c('EM_EVENTPROBABILITY', 'EM_CLASSIFICATION', 'R_FUNC_ELAPSED'),
        'length' = c(8, lenOutClass, 8),
        'type' = c('decimal', 'string', 'decimal'),
        'level' = c('interval', 'nominal', 'interval'))
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

    dict_MCE <- list('parameter'= '_MCE_', 'type'= 'num', 'label'= 'Misclassification Error',
                     'length'= 8, 'order'= 8, 'values'= array(c('_MCE_'), dim=(1)), 'preformatted' = FALSE)

    dict_THRESH <- list('parameter'= '_THRESH_', 'type'= 'num', 'label'= 'Threshold for MCE',
                        'length'= 8, 'order'= 9, 'values'= array(c('_THRESH_'), dim=(1)), 'preformatted' = FALSE)

    dict_C <- list('parameter'= '_C_', 'type'= 'num', 'label'= 'Area Under Curve',
                   'length'= 8, 'order'= 10, 'values'= array(c('_C_'), dim=(1)), 'preformatted' = FALSE)

    dict_GINI <- list('parameter'= '_GINI_', 'type'= 'num', 'label'= 'Gini Coefficient',
                     'length'= 8, 'order'= 11, 'values'= array(c('_GINI_'), dim=(1)), 'preformatted' = FALSE)

    dict_GAMMA <- list('parameter'= '_GAMMA_', 'type'= 'num', 'label'= 'Goodman-Kruskal Gamma',
                       'length'= 8, 'order'= 12, 'values'= array(c('_GAMMA_'), dim=(1)), 'preformatted' = FALSE)

    dict_TAU <- list('parameter'= '_TAU_', 'type'= 'num', 'label'= 'Kendall tau-a',
                     'length'= 8, 'order'= 13, 'values'= array(c('_TAU_'), dim=(1)), 'preformatted' = FALSE)

    dict_KS <- list('parameter'= '_KS_', 'type'= 'num', 'label'= 'Kolmogorov-Smirnov Statistic',
                    'length'= 8, 'order'= 14, 'values'= array(c('_KS_'), dim=(1)), 'preformatted' = FALSE)

    dict_KSCut <- list('parameter'= '_KSCut_', 'type'= 'num', 'label'= 'Probability Cut-off for Kolmogorov-Smirnov Statistic',
                       'length'= 8, 'order'= 15, 'values'= array(c('_KSCut_'), dim=(1)), 'preformatted' = FALSE)

    parameterMap <- list('_DataRole_'= dict_DataRole, '_PartInd_'= dict_PartInd, '_PartInd__f'=  dict_PartInd__f,
                         '_NObs_' = dict_NObs, '_ASE_' = dict_ASE, '_DIV_' = dict_DIV, '_RASE_' = dict_RASE,
                         '_MCE_' = dict_MCE, '_THRESH_' = dict_THRESH, '_C_' = dict_C, '_GINI_' = dict_GINI,
                         '_GAMMA_' = dict_GAMMA, '_TAU_' = dict_TAU, '_KS_' = dict_KS, '_KSCut_' = dict_KSCut)

    fitStats <- list('_DataRole_' = unbox('TRAIN'),
                     '_PartInd_' = unbox(1),
                     '_PartInd__f' = unbox('           1'),
                     '_NObs_' = unbox(nObservation), 
                     '_ASE_' = unbox(m_ase),
                     '_DIV_' = unbox(nObservation),
                     '_RASE_' = unbox(m_rase),
                     '_MCE_' = unbox(m_mce),
                     '_THRESH_' = unbox(threshPredProb),
                     '_C_' = unbox(m_auc),
                     '_GINI_' = unbox(m_gini),
                     '_GAMMA_' = unbox(m_gamma),
                     '_TAU_' = unbox(m_tau_a),
                     '_KS_' = unbox(m_ks),
                     '_KSCut_' = unbox(m_ks_cutoff))

    dmcas_fitstat <- list('name' = 'dmcas_fitstat',
                          'revision' = 0,
                          'order' = 0,
                          'parameterMap' = parameterMap,
                          'data' =  array(list(list('dataMap' = fitStats, 'rowNumber' = unbox(1))), dim = c(1)),
                          'version' = 1,
                          'xInteger' = FALSE,
                          'yInteger' = FALSE)

    write_json(dmcas_fitstat, path = paste(jsonFolder, 'dmcas_fitstat.json', sep = ''), pretty = TRUE, auto_unbox = TRUE, digits = 13)

    # 7. The dmcas_roc.json file
    dict_DataRole <- list('parameter' = '_DataRole_', 'type' = 'char', 'label' = 'Data Role',
                          'length' = 10, 'order' = 1, 'values' = array(c('_DataRole_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd <- list('parameter' = '_PartInd_', 'type' = 'num', 'label' = 'Partition Indicator',
                         'length' = 8, 'order' = 2, 'values' = array(c('_PartInd_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd__f <- list('parameter' = '_PartInd__f', 'type' = 'char', 'label' = 'Formatted Partition',
                            'length' = 12, 'order' = 3, 'values' = array(c('_PartInd__f'), dim=(1)), 'preformatted' = FALSE)

    dict_Column <- list('parameter' = '_Column_', 'type' = 'char', 'label' = 'Analysis Variable',
                        'length' = 32, 'order' = 4, 'values' = array(c('_Column_'), dim=(1)), 'preformatted' = FALSE)

    dict_Event <- list('parameter' = '_Event_', 'type' = 'char', 'label' = 'Event',
                       'length' = 1, 'order' = 5, 'values' = array(c('_Event_'), dim=(1)), 'preformatted' = FALSE)

    dict_Cutoff <- list('parameter' = '_Cutoff_', 'type' = 'num', 'label' = 'Cutoff',
                        'length' = 8, 'order' = 6, 'values' = array(c('_Cutoff_'), dim=(1)), 'preformatted' = FALSE)

    dict_Sensitivity <- list('parameter' = '_Sensitivity_', 'type' = 'num', 'label' = 'Sensitivity',
                             'length' = 8, 'order' = 7, 'values' = array(c('_Sensitivity_'), dim=(1)), 'preformatted' = FALSE)

    dict_Specificity <- list('parameter' = '_Specificity_', 'type' = 'num', 'label' = 'Specificity',
                             'length' = 8, 'order' = 8, 'values' = array(c('_Specificity_'), dim=(1)), 'preformatted' = FALSE)

    dict_FPR <- list('parameter' = '_FPR_', 'type' = 'num', 'label' = 'False Positive Rate',
                     'length' = 8, 'order' = 9, 'values' = array(c('_FPR_'), dim=(1)), 'preformatted' = FALSE)

    dict_OneMinusSpecificity <- list('parameter' = '_OneMinusSpecificity_', 'type' = 'num', 'label' = '1 - Specificity',
                                     'length' = 8, 'order' = 10, 'values' = array(c('_OneMinusSpecificity_'), dim=(1)), 'preformatted' = FALSE)

    parameterMap <- list('_DataRole_' = dict_DataRole, '_PartInd_' = dict_PartInd, '_PartInd__f' =  dict_PartInd__f,
                         '_Column_' = dict_Column, '_Event_' = dict_Event, '_Cutoff_' = dict_Cutoff, '_Sensitivity_' = dict_Sensitivity,
                         '_Specificity_' = dict_Specificity, '_FPR_' = dict_FPR, '_OneMinusSpecificity_' = dict_OneMinusSpecificity)

    roc_ncoord <- length(roc_cutoff)
    for (i in 1:roc_ncoord)
    {
        roc_coord <- list('_DataRole_' = unbox('TRAIN'),
                          '_PartInd_' = unbox(1),
                          '_PartInd__f' = unbox('           1'),
                          '_Column_' = unbox(targetVar), 
                          '_Event_' = unbox(eventValue),
                          '_Cutoff_' = unbox(roc_cutoff[i]),
                          '_Sensitivity_' = unbox(roc_tpr[i]),
                          '_Specificity_' = unbox(1.0 - roc_fpr[i]),
                          '_FPR_' = unbox(roc_fpr[i]),
                          '_OneMinusSpecificity_' = unbox(roc_fpr[i]))

        if (i > 1) roclist <- append(roclist, list(list('dataMap' = roc_coord, 'rowNumber' = unbox(i))))
        else roclist <- list(list('dataMap' = roc_coord, 'rowNumber' = unbox(i)))
    }

    dmcas_roc <- list('name' = 'dmcas_roc',
                      'revision' = 0,
                      'order' = 0,
                      'parameterMap' = parameterMap,
                      'data' =  array(roclist, dim = c(roc_ncoord)),
                      'version' = 1,
                      'xInteger' = FALSE,
                      'yInteger' = FALSE)

    write_json(dmcas_roc, path = paste(jsonFolder, 'dmcas_roc.json', sep = ''), pretty = TRUE, auto_unbox = TRUE, digits = 13)

    # 8. The dmcas_lift.json file
    dict_DataRole <- list('parameter' = '_DataRole_', 'type' = 'char', 'label' = 'Data Role',
                          'length' = 10, 'order' = 1, 'values' = array(c('_DataRole_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd <- list('parameter' = '_PartInd_', 'type' = 'num', 'label' = 'Partition Indicator',
                         'length' = 8, 'order' = 2, 'values' = array(c('_PartInd_'), dim=(1)), 'preformatted' = FALSE)

    dict_PartInd__f <- list('parameter' = '_PartInd__f', 'type' = 'char', 'label' = 'Formatted Partition',
                            'length' = 12, 'order' = 3, 'values' = array(c('_PartInd__f'), dim=(1)), 'preformatted' = FALSE)

    dict_Column <- list('parameter' = '_Column_', 'type' = 'char', 'label' = 'Analysis Variable',
                        'length' = 32, 'order' = 4, 'values' = array(c('_Column_'), dim=(1)), 'preformatted' = FALSE)

    dict_Event <- list('parameter' = '_Event_', 'type' = 'char', 'label' = 'Event',
                       'length' = 1, 'order' = 5, 'values' = array(c('_Event_'), dim=(1)), 'preformatted' = FALSE)

    dict_Depth <- list('parameter' = '_Depth_', 'type' = 'num', 'label' = 'Depth',
                       'length' = 8, 'order' = 7, 'values' = array(c('_Depth_'), dim=(1)), 'preformatted' = FALSE)

    dict_NObs <- list('parameter' = '_NObs_', 'type' = 'num', 'label' = 'Sum of Frequencies',
                      'length' = 8, 'order' = 8, 'values' = array(c('_NObs_'), dim=(1)), 'preformatted' = FALSE)

    dict_Gain <- list('parameter' = '_Gain_', 'type' = 'num', 'label' = 'Gain',
                      'length' = 8, 'order' = 9, 'values' = array(c('_Gain_'), dim=(1)), 'preformatted' = FALSE)

    dict_Resp <- list('parameter' = '_Resp_', 'type' = 'num', 'label' = '% Captured Response',
                      'length' = 8, 'order' = 10, 'values' = array(c('_Resp_'), dim=(1)), 'preformatted' = FALSE)

    dict_CumResp <- list('parameter' = '_CumResp_', 'type' = 'num',  'label' = 'Cumulative % Captured Response',
                         'length' = 8, 'order' = 11, 'values' = array(c('_CumResp_'), dim=(1)), 'preformatted' = FALSE)

    dict_PctResp <- list('parameter' = '_PctResp_', 'type' = 'num', 'label' = '% Response',
                         'length' = 8, 'order' = 12, 'values' = array(c('_PctResp_'), dim=(1)), 'preformatted' = FALSE)

    dict_CumPctResp <- list('parameter' = '_CumPctResp_', 'type' = 'num', 'label' = 'Cumulative % Response',
                            'length' = 8, 'order' = 13, 'values' = array(c('_CumPctResp_'), dim=(1)), 'preformatted' = FALSE)

    dict_Lift <- list('parameter' = '_Lift_', 'type' = 'num', 'label' = 'Lift',
                      'length' = 8, 'order' = 14, 'values' = array(c('_Lift_'), dim=(1)), 'preformatted' = FALSE)

    dict_CumLift <- list('parameter' = '_CumLift_', 'type' = 'num', 'label' = 'Cumulative Lift',
                         'length' = 8, 'order' = 15, 'values' = array(c('_CumLift_'), dim=(1)), 'preformatted' = FALSE)

    parameterMap <- list('_DataRole_' = dict_DataRole, '_PartInd_' = dict_PartInd, '_PartInd__f' = dict_PartInd__f,
                         '_Column_' = dict_Column, '_Event_' = dict_Event, '_Depth_' = dict_Depth,
                         '_NObs_' = dict_NObs, '_Gain_' = dict_Gain, '_Resp_' = dict_Resp, '_CumResp_' = dict_CumResp,
                         '_PctResp_' = dict_PctResp, '_CumPctResp_' = dict_CumPctResp, '_Lift_' = dict_Lift, '_CumLift_' = dict_CumLift)

    lift_ncoord <- nrow(lift_coordinate)
    for (i in 1:lift_ncoord)
    {
        lift_coord <- list('_DataRole_' = unbox('TRAIN'),
                           '_PartInd_' = unbox(1),
                           '_PartInd__f' = unbox('           1'),
                           '_Column_' = unbox(targetVar), 
                           '_Event_' = unbox(eventValue),
                           '_Depth_' = unbox(lift_coordinate[i,'accDecilePct']),
                           '_NObs_' = unbox(lift_coordinate[i,'decileN']),
                           '_Gain_' = unbox(lift_coordinate[i,'gainN']),
                           '_Resp_' = unbox(lift_coordinate[i,'gainPct']),
                           '_CumResp_' = unbox(lift_coordinate[i,'accGainPct']),
                           '_PctResp_' = unbox(lift_coordinate[i,'responsePct']),
                           '_CumPctResp_' = unbox(lift_coordinate[i,'accResponsePct']),
                           '_Lift_' = unbox(lift_coordinate[i,'lift']),
                           '_CumLift_' = unbox(lift_coordinate[i,'accLift']))

        if (i > 1) liftlist <- append(liftlist, list(list('dataMap' = lift_coord, 'rowNumber' = unbox(i))))
        else liftlist <- list(list('dataMap' = lift_coord, 'rowNumber' = unbox(i)))
    }

    dmcas_lift <- list('name' = 'dmcas_lift',
                       'revision' = 0,
                       'order' = 0,
                       'parameterMap' = parameterMap,
                       'data' =  array(liftlist, dim = c(lift_ncoord)),
                       'version' = 1,
                       'xInteger' = FALSE,
                       'yInteger' = FALSE)

    write_json(dmcas_lift, path = paste(jsonFolder, 'dmcas_lift.json', sep = ''), pretty = TRUE, auto_unbox = TRUE, digits = 13)

    # Put all the files in the jsonFolder to the ZIP package
    files2zip <- array(c(paste(jsonFolder, 'fileMetadata.json', sep = ''),
                         paste(jsonFolder, 'ModelProperties.json', sep = ''),
                         paste(jsonFolder, 'inputVar.json', sep = ''),
                         paste(jsonFolder, 'outputVar.json', sep = ''),
                         paste(jsonFolder, 'dmcas_fitstat.json', sep = ''),
                         paste(jsonFolder, 'dmcas_lift.json', sep = ''),
                         paste(jsonFolder, 'dmcas_roc.json', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_train.r', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_r_score.r', sep = ''),
                         paste(jsonFolder, analysisPrefix, '_r.rds', sep = '')), dim = c(10))

    zipr(zipfile = paste(jsonFolder, analysisPrefix, '_r.zip', sep = ''), files = files2zip, recurse = FALSE, include_directories = FALSE)

}   # end of function export_binary_modell
