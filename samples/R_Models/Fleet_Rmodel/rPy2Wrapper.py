
import os
os.environ['R_HOME'] = '<PATH>' # on server terminal, run "$ R RHOME"
from rpy2 import robjects
from rpy2.robjects.packages import importr
rScoreFunction = robjects.r("""
function(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time) {

rdsPath <- "/models/resources/viya/<UUID>/"

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


return (rScoreFunction(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time))
}
""")

def rPy2Score(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time):
    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION, R_FUNC_ELAPSED"

    if Speed_sensor is None or Speed_sensor == '':
        Speed_sensor = robjects.NA_Real
    else:
        Speed_sensor = float(Speed_sensor)

    if Vibration is None or Vibration == '':
        Vibration = robjects.NA_Real
    else:
        Vibration = float(Vibration)

    if Engine_Load is None or Engine_Load == '':
        Engine_Load = robjects.NA_Real
    else:
        Engine_Load = float(Engine_Load)

    if Coolant_Temp is None or Coolant_Temp == '':
        Coolant_Temp = robjects.NA_Real
    else:
        Coolant_Temp = float(Coolant_Temp)

    if Intake_Pressure is None or Intake_Pressure == '':
        Intake_Pressure = robjects.NA_Real
    else:
        Intake_Pressure = float(Intake_Pressure)

    if Engine_RPM is None or Engine_RPM == '':
        Engine_RPM = robjects.NA_Real
    else:
        Engine_RPM = float(Engine_RPM)

    if Speed_OBD is None or Speed_OBD == '':
        Speed_OBD = robjects.NA_Real
    else:
        Speed_OBD = float(Speed_OBD)

    if Intake_Air is None or Intake_Air == '':
        Intake_Air = robjects.NA_Real
    else:
        Intake_Air = float(Intake_Air)

    if Flow_Rate is None or Flow_Rate == '':
        Flow_Rate = robjects.NA_Real
    else:
        Flow_Rate = float(Flow_Rate)

    if Throttle_Pos is None or Throttle_Pos == '':
        Throttle_Pos = robjects.NA_Real
    else:
        Throttle_Pos = float(Throttle_Pos)

    if Voltage is None or Voltage == '':
        Voltage = robjects.NA_Real
    else:
        Voltage = float(Voltage)

    if Ambient is None or Ambient == '':
        Ambient = robjects.NA_Real
    else:
        Ambient = float(Ambient)

    if Accel is None or Accel == '':
        Accel = robjects.NA_Real
    else:
        Accel = float(Accel)

    if Engine_Oil_Temp is None or Engine_Oil_Temp == '':
        Engine_Oil_Temp = robjects.NA_Real
    else:
        Engine_Oil_Temp = float(Engine_Oil_Temp)

    if Speed_GPS is None or Speed_GPS == '':
        Speed_GPS = robjects.NA_Real
    else:
        Speed_GPS = float(Speed_GPS)

    if GPS_Longitude is None or GPS_Longitude == '':
        GPS_Longitude = robjects.NA_Real
    else:
        GPS_Longitude = float(GPS_Longitude)

    if GPS_Latitude is None or GPS_Latitude == '':
        GPS_Latitude = robjects.NA_Real
    else:
        GPS_Latitude = float(GPS_Latitude)

    if GPS_Bearing is None or GPS_Bearing == '':
        GPS_Bearing = robjects.NA_Real
    else:
        GPS_Bearing = float(GPS_Bearing)

    if GPS_Altitude is None or GPS_Altitude == '':
        GPS_Altitude = robjects.NA_Real
    else:
        GPS_Altitude = float(GPS_Altitude)

    if Turbo_Boost is None or Turbo_Boost == '':
        Turbo_Boost = robjects.NA_Real
    else:
        Turbo_Boost = float(Turbo_Boost)

    if Trip_Distance is None or Trip_Distance == '':
        Trip_Distance = robjects.NA_Real
    else:
        Trip_Distance = float(Trip_Distance)

    if Litres_Per_km is None or Litres_Per_km == '':
        Litres_Per_km = robjects.NA_Real
    else:
        Litres_Per_km = float(Litres_Per_km)

    if Accel_Ssor_Total is None or Accel_Ssor_Total == '':
        Accel_Ssor_Total = robjects.NA_Real
    else:
        Accel_Ssor_Total = float(Accel_Ssor_Total)

    if CO2 is None or CO2 == '':
        CO2 = robjects.NA_Real
    else:
        CO2 = float(CO2)

    if Trip_Time is None or Trip_Time == '':
        Trip_Time = robjects.NA_Real
    else:
        Trip_Time = float(Trip_Time)

    routput = rScoreFunction(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time)

    if isinstance(routput[0][0], type(robjects.NA_Logical)):
        EM_EVENTPROBABILITY = None
    else:
        EM_EVENTPROBABILITY = routput[0][0]

    if isinstance(routput[1][0], type(robjects.NA_Logical)):
        EM_CLASSIFICATION = None
    else:
        EM_CLASSIFICATION = routput[1][0]

    if isinstance(routput[2][0], type(robjects.NA_Logical)):
        R_FUNC_ELAPSED = None
    else:
        R_FUNC_ELAPSED = routput[2][0]


    return (EM_EVENTPROBABILITY, EM_CLASSIFICATION, R_FUNC_ELAPSED)