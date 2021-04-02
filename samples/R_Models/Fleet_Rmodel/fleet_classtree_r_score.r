# title: fleet_classtree_r_score.r
# author: SAS Institute
# date: July 30, 2020

library (rpart)

rScoreFunction <- function(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD,
                           Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS,
                           GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance,
                           Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time)
{
   #Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION, R_FUNC_ELAPSED

   # Measure execution time of this function
   start_time <- Sys.time()

   # Load the R model object if necessary
   if (!exists("myClassTree"))
   {
      assign("myClassTree", readRDS(file = paste(rdsPath, 'fleet_classtree_r.rds', sep = '')), envir = .GlobalEnv)
   }

   # Threshold for the misclassification error
   threshPredProb <- 0.226917057902973

   input_array <- data.frame('Speed_sensor' = Speed_sensor, 'Vibration' = Vibration, 'Engine_Load' = Engine_Load,
                             'Coolant_Temp' = Coolant_Temp, 'Intake_Pressure' = Intake_Pressure, 'Engine_RPM' = Engine_RPM,
                             'Speed_OBD' = Speed_OBD, 'Intake_Air' = Intake_Air, 'Flow_Rate' = Flow_Rate,
                             'Throttle_Pos' = Throttle_Pos, 'Voltage' = Voltage, 'Ambient' = Ambient, 'Accel' = Accel,
                             'Engine_Oil_Temp' = Engine_Oil_Temp, 'Speed_GPS' = Speed_GPS, 'GPS_Longitude' = GPS_Longitude,
                             'GPS_Latitude' = GPS_Latitude, 'GPS_Bearing' = GPS_Bearing, 'GPS_Altitude' = GPS_Altitude,
                             'Turbo_Boost' = Turbo_Boost, 'Trip_Distance' = Trip_Distance, 'Litres_Per_km' = Litres_Per_km,
                             'Accel_Ssor_Total' = Accel_Ssor_Total, 'CO2' = CO2, 'Trip_Time' = Trip_Time)

   predProb <- predict(myClassTree, newdata = input_array, type = 'prob', na.action = na.omit)

   # Retrieve the event probability and determine the predicted target category
   if (!is.na(predProb[2]))
   {
      EM_EVENTPROBABILITY = predProb[2]
      EM_CLASSIFICATION <- ifelse(EM_EVENTPROBABILITY >= threshPredProb, '1', '0')
   }
   else
   {
      EM_EVENTPROBABILITY <- NA
      EM_CLASSIFICATION <- ' '
   }

   # Measure execution time of this function
   end_time <- Sys.time()
   elapsed_second <- end_time - start_time

   output_list <- list('EM_EVENTPROBABILITY' = EM_EVENTPROBABILITY, 'EM_CLASSIFICATION' = EM_CLASSIFICATION,
                       'R_FUNC_ELAPSED' = elapsed_second[[1]])
   return(output_list)
}
