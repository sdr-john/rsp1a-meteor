#!/bin/bash

# This is a modified version of the original receive_and_process_
# satellite script. It has been modified to enable Meteor-M 2/M2-2 decoding

# $1 = Satellite Name
# $2 = Frequency
# $3 = FileName base
# $4 = TLE File
# $5 = EPOC start time
# $6 = Time to capture

# Create String to check satellite name

str="METEOR-M 2"

# Here for simplicity, the main steps of this script are as follows:
# 1. RAW file is created first @ 250kb/sec I/Q with playsdr (rather than using a pipe)
# 2. Use sox to convert to 140kb/sec I/Q samples
# 3. Use meteor_demod to demodulate the QPSK/OQPSK signal to DAT format
# 4. Use medet to decode the signal and conver to BMP format 
# 
# Useful M2/M2-2 Status Website: http://happysat.nl/Meteor/html/Meteor_Status.html
#

# Code for Sdrplay RSP1A

# Currently decode with RSP1a - decimation x8 for zero-if mode currently coded up (250k sample rate)
# sox then subsamples to a rate of 140k sample rate for decoding

timeout $6 /home/ubuntu/meteor/sdrplay/play_sdr -f ${2}M -R 50 -v 0 $3.raw 

sox -t raw -e signed -c 2 -b16 -r 250000 $3.raw $3.wav rate 140000

PassStart=`expr $5 + 90`

if [ -e $3.wav ]
  then

  # Now can safely delete the raw file

  sudo rm $3.raw

  # Check which satellite we are decoding

  if [ "$1" == "$str" ]
     then

     # Use meteor_demod to demodulate METEOR-M 2 transmission (QPSK data, PLL BW 50)

     /home/ubuntu/meteor/bin/meteor_demod -B -q -s 140000 -m qpsk -b 50 -o $3.dat $3.wav

     # Use medet to decode this data into image format
     # currently Meteor-M 2 is using APID 68 not 66 , so can use -r 68

     /home/ubuntu/meteor/bin/medet $3.dat $3 -Q

     else

     # Use meteor_demod to demodulate METEOR-M2 2 transmission (OQPSK data, PLL BW 50Hz)

     /home/ubuntu/meteor/bin/meteor_demod -B -q -s 140000 -m oqpsk -b 50 -o $3.dat $3.wav

     # Use diff option in medet to decode METEOR-M2 2 satellite

     /home/ubuntu/meteor/bin/medet $3.dat $3 -Q -diff 

   fi

fi

#Finally clean up wav file

if [ -e $3.dat ]
then 
     sudo rm $3.wav
fi
