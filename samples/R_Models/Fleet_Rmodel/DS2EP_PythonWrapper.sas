data sasep.out;
   dcl package pymas pm;
   dcl package logger logr('App.tk.MAS');
   dcl varchar(32767) character set utf8 pypgm;
   dcl double resultCode revision;
   dcl double Accel;
   dcl double Accel_Ssor_Total;
   dcl double Ambient;
   dcl double CO2;
   dcl double Coolant_Temp;
   dcl double Engine_Load;
   dcl double Engine_Oil_Temp;
   dcl double Engine_RPM;
   dcl double Flow_Rate;
   dcl double GPS_Altitude;
   dcl double GPS_Bearing;
   dcl double GPS_Latitude;
   dcl double GPS_Longitude;
   dcl double Intake_Air;
   dcl double Intake_Pressure;
   dcl double Litres_Per_km;
   dcl double Speed_GPS;
   dcl double Speed_OBD;
   dcl double Speed_sensor;
   dcl double Throttle_Pos;
   dcl double Trip_Distance;
   dcl double Trip_Time;
   dcl double Turbo_Boost;
   dcl double Vibration;
   dcl double Voltage;
   dcl varchar(100) EM_CLASSIFICATION;
   dcl double EM_EVENTPROBABILITY;
   dcl double R_FUNC_ELAPSED;

   method score(
   double Speed_sensor,
   double Vibration,
   double Engine_Load,
   double Coolant_Temp,
   double Intake_Pressure,
   double Engine_RPM,
   double Speed_OBD,
   double Intake_Air,
   double Flow_Rate,
   double Throttle_Pos,
   double Voltage,
   double Ambient,
   double Accel,
   double Engine_Oil_Temp,
   double Speed_GPS,
   double GPS_Longitude,
   double GPS_Latitude,
   double GPS_Bearing,
   double GPS_Altitude,
   double Turbo_Boost,
   double Trip_Distance,
   double Litres_Per_km,
   double Accel_Ssor_Total,
   double CO2,
   double Trip_Time,
   in_out double resultCode,
   in_out double EM_EVENTPROBABILITY,
   in_out varchar(100) EM_CLASSIFICATION,
   in_out double R_FUNC_ELAPSED);

      resultCode = revision = 0;
      if null(pm) then do;
         pm = _new_ pymas();
         resultCode = pm.useModule('model_exec_0b6f3206-bee7-4a4c-b7e6-2519a70f8297', 1);
         if resultCode then do;
            resultCode = pm.appendSrcLine('import sys');
            resultCode = pm.appendSrcLine('sys.path.append("/models/resources/viya/<UUID>/")');
            resultCode = pm.appendSrcLine('import rPy2Wrapper');
            resultCode = pm.appendSrcLine('def rPy2Score(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time):');
            resultCode = pm.appendSrcLine('    "Output: EM_EVENTPROBABILITY, EM_CLASSIFICATION, R_FUNC_ELAPSED"');
            resultCode = pm.appendSrcLine('    return rPy2Wrapper.rPy2Score(Speed_sensor, Vibration, Engine_Load, Coolant_Temp, Intake_Pressure, Engine_RPM, Speed_OBD, Intake_Air, Flow_Rate, Throttle_Pos, Voltage, Ambient, Accel, Engine_Oil_Temp, Speed_GPS, GPS_Longitude, GPS_Latitude, GPS_Bearing, GPS_Altitude, Turbo_Boost, Trip_Distance, Litres_Per_km, Accel_Ssor_Total, CO2, Trip_Time)');

            revision = pm.publish(pm.getSource(), 'model_exec_0b6f3206-bee7-4a4c-b7e6-2519a70f8297');
            if ( revision < 1 ) then do;
               logr.log( 'e', 'py.publish() failed.');
               resultCode = -1;
               return;
            end;
         end;
      end;

      resultCode = pm.useMethod('rPy2Score');
      if resultCode then do;
         logr.log('E', 'useMethod() failed. resultCode=$s', resultCode);
         return;
      end;
      resultCode = pm.setDouble('Speed_sensor', Speed_sensor);
      if resultCode then
         logr.log('E', 'setDouble for Speed_sensor failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Vibration', Vibration);
      if resultCode then
         logr.log('E', 'setDouble for Vibration failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Engine_Load', Engine_Load);
      if resultCode then
         logr.log('E', 'setDouble for Engine_Load failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Coolant_Temp', Coolant_Temp);
      if resultCode then
         logr.log('E', 'setDouble for Coolant_Temp failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Intake_Pressure', Intake_Pressure);
      if resultCode then
         logr.log('E', 'setDouble for Intake_Pressure failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Engine_RPM', Engine_RPM);
      if resultCode then
         logr.log('E', 'setDouble for Engine_RPM failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Speed_OBD', Speed_OBD);
      if resultCode then
         logr.log('E', 'setDouble for Speed_OBD failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Intake_Air', Intake_Air);
      if resultCode then
         logr.log('E', 'setDouble for Intake_Air failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Flow_Rate', Flow_Rate);
      if resultCode then
         logr.log('E', 'setDouble for Flow_Rate failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Throttle_Pos', Throttle_Pos);
      if resultCode then
         logr.log('E', 'setDouble for Throttle_Pos failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Voltage', Voltage);
      if resultCode then
         logr.log('E', 'setDouble for Voltage failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Ambient', Ambient);
      if resultCode then
         logr.log('E', 'setDouble for Ambient failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Accel', Accel);
      if resultCode then
         logr.log('E', 'setDouble for Accel failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Engine_Oil_Temp', Engine_Oil_Temp);
      if resultCode then
         logr.log('E', 'setDouble for Engine_Oil_Temp failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Speed_GPS', Speed_GPS);
      if resultCode then
         logr.log('E', 'setDouble for Speed_GPS failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('GPS_Longitude', GPS_Longitude);
      if resultCode then
         logr.log('E', 'setDouble for GPS_Longitude failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('GPS_Latitude', GPS_Latitude);
      if resultCode then
         logr.log('E', 'setDouble for GPS_Latitude failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('GPS_Bearing', GPS_Bearing);
      if resultCode then
         logr.log('E', 'setDouble for GPS_Bearing failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('GPS_Altitude', GPS_Altitude);
      if resultCode then
         logr.log('E', 'setDouble for GPS_Altitude failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Turbo_Boost', Turbo_Boost);
      if resultCode then
         logr.log('E', 'setDouble for Turbo_Boost failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Trip_Distance', Trip_Distance);
      if resultCode then
         logr.log('E', 'setDouble for Trip_Distance failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Litres_Per_km', Litres_Per_km);
      if resultCode then
         logr.log('E', 'setDouble for Litres_Per_km failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Accel_Ssor_Total', Accel_Ssor_Total);
      if resultCode then
         logr.log('E', 'setDouble for Accel_Ssor_Total failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('CO2', CO2);
      if resultCode then
         logr.log('E', 'setDouble for CO2 failed.  resultCode=$s', resultCode);
      resultCode = pm.setDouble('Trip_Time', Trip_Time);
      if resultCode then
         logr.log('E', 'setDouble for Trip_Time failed.  resultCode=$s', resultCode);
      resultCode = pm.execute();
      if (resultCode) then
         logr.log('E', 'Error: pm.execute failed.  resultCode=$s', resultCode);
      else do;
         EM_EVENTPROBABILITY = pm.getDouble('EM_EVENTPROBABILITY');
         EM_CLASSIFICATION = pm.getString('EM_CLASSIFICATION');
         R_FUNC_ELAPSED = pm.getDouble('R_FUNC_ELAPSED');
      end;
   end;

   method run();
      set SASEP.IN;
      score(Speed_sensor,Vibration,Engine_Load,Coolant_Temp,Intake_Pressure,Engine_RPM,Speed_OBD,Intake_Air,Flow_Rate,Throttle_Pos,Voltage,Ambient,Accel,Engine_Oil_Temp,Speed_GPS,GPS_Longitude,GPS_Latitude,GPS_Bearing,GPS_Altitude,Turbo_Boost,Trip_Distance,Litres_Per_km,Accel_Ssor_Total,CO2,Trip_Time, resultCode, EM_EVENTPROBABILITY,EM_CLASSIFICATION,R_FUNC_ELAPSED);
   end;
enddata;
