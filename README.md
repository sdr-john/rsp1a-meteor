# rsp1a-meteor
This repository contains shell scripts and some modified sdrplay software to help decode the Meteor M2 and M2-2 Satellites.

INTRODUCTION:

This code will hopefully help you decode signals from METEOR-M2 and M2-2 satellites, using an Sdrplay RSP1a software radio with a Raspberry Pi 3. I found that this can pick up the signals better than an RTL-SDR stick with my setup. The instructions assume that you are familiar with using the Linux command line and downloading/installing software packages.

My code is based on the instructions presented here for decoding NOAA satellites with an RTL-SDR:

[NOAA] https://www.instructables.com/id/Raspberry-Pi-NOAA-Weather-Satellite-Receiver/

Every time you see [NOAA] in the instructions below, it refers back to this URL. If you have an RTL-SDR, it would make sense to try NOAA satellite decoding first to get familiar with the process.

This software should work but is provided “as-is” under the MIT licence and is not currently very optimized. I am happy to receive feedback and suggestions on how it might be improved.

MY HARDWARE SETUP:

I use the following equipment:
1.	RTL-SDR Blog Multipurpose Dipole Antenna Kit from the www.rtl-sdr.com shop. This is configured to form a horizontal V-Antenna matching dimensions as best I could to these instructions:

 http://lna4all.blogspot.com/2017/02/diy-137-mhz-wx-sat-v-dipole-antenna.html
 
I have mounted mine horizontally on a stand so it is about 1 metre off the ground. My antenna is mounted in an attic and pointed North - this seems to work well. The antenna is connected via a long coax cable to the pre-amplifier below.

2.	Uptronics 137.5MHz pre-amplifier:

https://store.uputronics.com/index.php?route=product/product&product_id=94

You will need a male-male SMA coupler such as shown on this page to connect to the RSP1a radio. Other high gain pre-amplifiers that operate around this frequency band can also be used.

3.	Sdrplay RSP1a software radio:

https://www.sdrplay.com/rsp1a/

4.	Raspberry Pi 3B computer with USB cable to connect to the RSP1a software radio. I assume that you will set this up with a current linux distribution. I personally use Ubuntu, but the instructions at the [NOAA] link in Step 1 above briefly describes installing Raspbian.

SUBDIRECTORY STRUCTURE:

This Git repository contains three subfolders:

bin – directory to put executables for METEOR satellite demodulation and decoding.

predict – directory containing scripts that automatically run 

sdrplay – directory containing play_sdr executable that records data from the RSP1a device.

SETTING UP THE RSP1a RADIO:

You need to download the Sdrplay API/Hardware driver (V2.13) from

https://www.sdrplay.com/downloads/

There is also a full linux distribution available for the RSP1a if your prefer that to Raspbian. Otherwise, please download and install the driver. A simple test for it working is to plug in your RSP1a. If you then type “lsusb” on the command line and press return, one of the devices listed should have the same 8-digit ID as this:

Bus 001 Device 005: ID 1df7:3000

If it is working, download this Github archive. Go to the sdrplay subdirectory in your local copy. The code here is based on the Sdrplay github archive:

https://github.com/SDRplay/examples

I have made minor updates to the existing code to use 8 times decimation of signal (sampling at 250 kHz instead of the default 2 MHz) and switching on the Bias-T control to power the pre-amplifier. These functions can be found at lines 382-395 of the play_sdr.c file, in case you wish to edit them.

When ready type “make” and press return, then the play_sdr program should compile successfully with the hardware driver installed. You can then check that the program works as follows:

./play_sdr -f 137.1M -R 50 -v 1 test.raw

The -v option prints out diagnostic information to tell you what the RSP1a is doing. Press CTRL+C to exit after a few seconds. You should find a binary file test.raw containing the sampled I/Q data from the RSP1a.

SATELLITE DECODING SOFTWARE:

We now need to install the following packages that are used in the scripts:

sox – post-process the RAW data file from the play_sdr program to generate a WAV file for decoding

at – job scheduler 

predict – programme to track METEOR M2/M2-2 satellite orbits.

There are simple instructions for installation at Step 2 of [NOAA] – you also need to input your precise location to the predict program, as described in Step 3 of [NOAA].

The next step is to install a demodulator for the QPSK modulation used in the METEOR satellites. You can obtain the latest version of meteor_demod from this Github location:

https://github.com/dbdexter-dev/meteor_demod

Download the files and then compile the “meteor_demod” program following the instructions there.

Finally, you need a decoder that converts the data provided by meteor_demod into a BMP image. I use the following one from Github:

https://github.com/artlav/meteor_decoder

Note that this program will NOT produce a BMP image file, unless some of the METEOR satellite data is successfully decoded. This software is written in Pascal, so you need to install the Free Pascal Compiler (fpc) to compile it from the code provided. The Readme file on Github also gives you links to pre-compiled versions, including for the Raspberry Pi.

It is recommended that you put copies of both the “meteor_demod” and “medet” executable programs in the “bin” subdirectory for use by the satellite decoding scripts.

SATELLITE DECODING SCRIPTS:

The scripts are located in the sub-directory “predict”. Their structure is very similar to that described in Step 4 of the [NOAA] link above, so please read that, to get an idea of how things work. In summary, the scripts do the following:

schedule_all.sh – top level scripts that downloads a file of satellite orbits and determines which satellites to decode. A warning is printed by default to ask the user to check all script path-names are correct.

schedule_meteor.sh – This does the work of determining the visible orbits of each satellite on the day the script is run and sets up automatic jobs to decode the satellite data.

receive_and_process_meteor.sh – This script runs the play_sdr program to capture data from each satellite pass and then decodes it. If successful, it produces a satellite image in BMP format.

The scripts contain explicit paths to each other, assuming they are all located in:

/home/ubuntu/meteor/predict/

If this does not match your setup, you need to change the path accordingly in all three files, so the code will work. For example, if you are using Raspbian, your username is likely to be “pi” not “ubuntu”.

Once you are happy that the script will run, you need to make all three executable. So for schedule_all.sh, you should do:

chmod +x schedule_all.sh

Repeat this command for the other two script files.

To automate satellite captures, you need to type “crontab -e” and press return on the command line. Add the following line at the bottom of your file and save it:

1 0 * * * /home/ubuntu/meteor/predict/schedule_all.sh

This runs the schedule_all.sh script at 1 minute past midnight each day. Remember to update your path as needed for your system. You can also run this script directly from the command line as:

/home/ubuntu/meteor/predict/schedule_all.sh

This will find all of the remaining meteor passes for the day. All of the datafiles are stored in the top level meteor directory.

IMPORTANT PARAMETERS AND INFORMATION

There are comments in the scripts to try to explain important steps in the code. The most important settings to check are as follows:

schedule_all.sh – this sets the carrier frequency of the data signals for the M2/M2-2 satellites in MHz, currently 137.1 MHz and 137.9 MHz.

schedule_meteor.sh – This sets the minimum orbit angle where the data is processed, currently greater than 55 deg.

receive_and_process_meteor.sh – The “-R” flag sets the gain reduction value, currently 50. This is a critical setting and if wrongly set may cause the analogue-to-digital converter to overload or too low a signal-to-noise ratio for decoding. Testing your setup first using, e.g.  the Windows SDRuno software, may be sensible to view signal spectra and to see what gain settings are best.

This webpage gives useful information about the current status of the METEOR satellites:

http://happysat.nl/Meteor/html/Meteor_Status.html

This website allows you to obtain satellite passes for your location for the next ten days:

https://www.n2yo.com/

Meteor M2 has catalogue number 40069 and M2-2 has catalogue number 44387.
