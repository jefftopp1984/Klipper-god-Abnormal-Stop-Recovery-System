******* KLIPPER-GOD RECOVERY SYSTEM ********

Here is a TRUE WORKING Print Recovery System for Open-Source Klipper Users. This system is NOT UNSAFE for your equipment like other PLR systems such as Yumi and Omega that BLINDLY assume that the X and Y are at 0 when setting the kinematic position of the printer! I have tried those systems and they attempt to run the X and Y axes BEYOND THEIR MECHANICAL LIMITS because they do not home the X and Y axes, but instead set the Kinematic Position of X and Y to 0! It flat out P!$$ES ME OFF that these systems have been published for others to use when they BLANTANTLY DISREGARD AND BYPASS KLIPPER SAFETY SYSTEMS!!!!!! This system DOES NOT DO THAT. This system RESPECTS a user's equipment, NO downward movement is done until the user is ready for it, and it DOES NOT bypass ANY of Klipper's built-in safety measures! The USER has the final say, NOTHING is assumed to be correct, and the user can CANCEL the process at any point during the resume sequence. This system has been modeled very largely around the OEM recovery systems like Creality's factory recovery system on the Sonic Pad, but have a few enhancements over their system: 1, it removes the nozzle from the print the moment the temperature reaches target -50C, then it waits for the bed to fully heat before moving anything on the printer. The work flow is as follows:

Normal Print → Power Loss → Prompt → Recover File → Z Verify → Resume

- The slicer passes values to the _LOG_PROGRESS macro which then saves these values to variables.cfg as the print progresses. This is in the after layer change gcode or layer change gcode. 

- The start print macro or gcode issues _SAVE_FILE which in turn writes a current_file.txt file to the gcode folder and you will see this in your Jobs list. The _SAVE_FILE macro also flags a variable that marks that a print is in progress.

- Upon restart after a failure, ANY kind of failure, not just a power loss, a delayed gcode checks this variable and will display a message asking the user if they want to resume the interrupted print. If the user cancels, all data is purged and the tracking variables are set to 0. If the user accepts, the printer will immediately turn the heaters back on, lift Z off the print once it reaches target - 50C, and wait for the bed to return to temperature. A new file will also be written at this point named "Recovered.gcode". This will also show in the Jobs list, but will not have any thumbnail data.

- Upon the bed reaching full target temperature, which is logged every layer change, the printer will home X and Y, center the tool head, then display a message with all of the saved data. This is the first "sanity check" that the user must perform. Does the data look plausible? If so, the user can continue. If it looks wrong, they can cancel at this point. If they cancel, all data will be purged. The recovery file that was written will take 30-seconds to be removed. This is by design as the same function is used to remove it after the print completes and this delay allows Moonraker to fully exit and close the file before it is deleted.

- Once the user accepts, he nozzle will move to the start position of the previously-recorded layer, then prompt the user to place a sheet of paper, such as a standard sheet of printer paper that is known to be 0.1mm, or 1 mil, thick and click ok.

- At this point, the nozzle temperature is dropped to 10C below the BED target temperature to prevent melting for the gap check. Once the nozzle has reached that point, the user is prompted to ensure there is no oozed filament on the nozzle that will interfere with the gap check and remove any that is present, then click ok.

- The nozzle drops to the resumed height + 0.1mm and the user is prompted to move the paper around on the bed. *******IT IS HIGHLY RECOMMENDED THAT YOU RUN SOME TEST PRINTS AND TRIGGER THIS TO GET A FEEL FOR HOW IT NEEDS TO BE!******* Those who do pre-print bed gap checks will notice the required resistance feels MUCH TIGHTER for this check, but not tight enough to tear the paper or totally resist movement without tearing the paper.

- The user is asked if the resistance is correct. If so, the user is given the final prompt below. If incorrect, a new box will pop up with adjustments that can be made. Every adjustment will trigger a 5mm hop to ensure stiction in the lead screws and stepper motors does not cause error from micro steps of the motors. There very well may be SIGNIFICANT adjustment needed due to most Z steppers jumping when energized. Since that jump occurs right at the moment the kinematic position of the printer is set, the calibration could be off as far as 0.05mm. This is known behavior and since a true Z home does not happen, that is why this calibration step is so critical. Once the calibration is complete, the user clicks done and is given one final sanity check prompt.

- The final prompt tells the user to remove the check paper, ensure that the print is still adhered to the bed properly, and ensure they are actually ready for the resume to happen. Once they click ok, the nozzle lifts 10mm, is set to the full temperature, and when the nozzle stabilizes at that temperature, the print resumes automatically.


WHY THIS IS SAFE:

- It DOES NOT violate Klipper safety protocols
- It involves USER VERIFICATION
- NO DOWNWARD MOVEMENT occurs until the user has done a sanity check on the reported data
- A TRUE HOME of X and Y are performed
- Z is NOT trusted until the user physically verifies it!
- Nozzle Temps are carefully applied to prevent print and/or printer damage
- The user can ABORT the resume at any stage in the process
- It DOES NOT automatically resume
- Several Sanity Checks happen along the way
- It WILL NOT run any axes beyond their mechanical limits like other published PLR systems

Why this isn't just a normal PLR:

- EVERYTHING is tracked throughout the print progress
- It works for ANY KIND of abnormal stop, NOT just Power Loss
- It DOES NOT require any special hardware to initiate a "Klipper Panic" situation when a pin is losing voltage
- It CAN be used with a UPS and a PAUSE_NEXT_LAYER macro to provide true seamless resumes after a power loss as long as the UPS battery does not expire before the end of that layer
- It sets a NON-VOLATILE variable that is checked on restart from ANY condition
- It will actually allow a resume after a USB Disconnect as well


***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************


All of the included macros and shell commands are given in the zip file. It is written for a STANDARD Debian Sonic pad natively, so Raspberry Pi users will need to edit the paths in the shell commands to ensure they are correct. Normally, the only difference is as follows:

- The paths natively are /home/sonic/printer_data/config/, /home/sonic/klipper/, and /home/sonic/printer_data/gcodes/

- Pi users normally will need /home/pi/printer_data/config/. /home/pi/klipper/, and /home/pi/printer_data/gcodes/

Please place the macros and shell commands in the appropriate locations, outlined in the "ASR Macros and Commands.txt" file

Users will also need to verify the port number in save_current_file.sh matches your printer's port number. It was designed for a PER INSTANCE installation. User with multiple printers will need SEPARATE COPIES of the shell commands in each printer's folders and verify that the save_variables file is correct. While it is possible to use a common variables.cfg file under /home/sonic/klipper/ or /home/pi/klipper/, it is NOT RECOMMENDED because if both printers reach a layer change at the exact same moment, data can get corrupted. Users will also need to make sure the svv.* variables are named appropriately for their setup. As stated, this is designed for a SINGLE PRINTER, but can easily be used in multiple instances as long as the paths are reflected correctly.

Users will also have to ensure that the shell commands are executable via SSH by using:

********* REMEMBER, MAKE SURE THESE PATHS ARE CORRECT FOR YOUR SPECIFIC SETUP! **********

chmod -x /home/sonic/printer_data/config/save_current_file.sh

and

chmod -x /home/sonic/printer_data/config/print_recovery.sh

AND that CRLF has not been applied using:

cd /home/sonic/printer_data/config/

followed by:

sed -i 's/\r$//' *.sh

and: (this is optional and really should only be used if your system has issues running the shell commands. It is also run from inside the /home/sonic/printer_data/config/ folder or equivalent.)

dos2unix *.sh

After editing paths or config filenames, use FIRMWARE_RESTART
(not just RESTART or UI refresh).


Finally, ENJOY HAVING THE PEACE OF MIND THAT YOU HAVE A PLAN B IN THE CASE OF A PRINT FAILURE!

******* KLIPPER-GOD ABNORMAL STOP RECOVERY SYSTEM was written and developed by Klipper-god. *******
