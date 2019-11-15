#!/bin/bash

# Print path warning

echo "WARNING: Check all program paths carefully in these scripts"

# Update Satellite Information 

wget -qr https://www.celestrak.com/NORAD/elements/weather.txt -O /home/ubuntu/meteor/predict/weather.txt
grep "METEOR-M 2" /home/ubuntu/meteor/predict/weather.txt -A 2 >> /home/ubuntu/meteor/predict/weather.tle
grep "METEOR-M2 2" /home/ubuntu/meteor/predict/weather.txt -A 2 >> /home//ubuntu/meteor/predict/weather.tle



#Remove all AT jobs

for i in `atq | awk '{print $1}'`;do atrm $i;done


# Schedule Satellite Passes:
# At present M2 using 137.1 MHz/M2-2 using 137.9 MHz

/home/ubuntu/meteor/predict/schedule_meteor.sh "METEOR-M 2" 137.1000 
/home/ubuntu/meteor/predict/schedule_meteor.sh "METEOR-M2 2" 137.9000 
