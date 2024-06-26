# id09-1_CDI_ivu18_2.4m

## Disclaimer
This code is an incomplete example which is largely untested.  There is no guarantee of functionality or usability.  It is only meant as an example.  Use at your own risk.

## CSS
Some starting CSS files are located in the CSS subfolder.  The starting page for this is main.opi, which should have the correct MACROs so this should be the default entry point.

## EPICS
The EPICS portion for most IO, coordinate systems, etc exists.  Most things specific to the ID controls will be found in IVU18App/Db/IVU18.db and IVU18App/Db/ivu18_motorstatus.template.  Other files in this folder contain some standard definitions.  The startup script currently runs ouf of the iocBoot/iocapp/ directory.  cd to this directory then run ./st.cmd

## Motor Setup
Motors are configured the following way:
* #1 - Gap Upstream (GU)
* #2 - Gap Downstream (GD)
* #3 - Elevation Upstream (EU)
* #4 - Elevation Downstream (ED)

The definition of user coordinates follows the following definition:
* Gap = (GU + GD) / 2
* Taper = GD - GU
* Elevation = (EU + ED) / 2
* Tilt = ED - EU

This means that for positive taper the downstream gap is larger than the upstream gap.  For positive tilt the downstream side is higher than the upstream side.

## Coordinate Systems (CS) and Motion Programs
It is assumed that typical usage will be gap and taper motion (without changing elevation or tilt).
* CS2 & PROG02 is used for Gap + Taper motion.
* CS3 & PROG03 is used for Elevation + Tilt motion.
* CS4 & PROG04 is used for combined motion Gap + Taper + Elevation + Tilt.

Position reporting for all coordinate systems is done in PLC18 to avoid duplicate code.


## Files and what is in them
These files live somewhere in the following Project structure.
```
Project/PMAC Script Language/Global Includes
Project/PMAC Script Language/Kinematic Routines
Project/PMAC Script Language/Libraries
Project/PMAC Script Language/Motion Programs
Project/PMAC Script Language/PLC Programs
```

### EncoderTable.pmh
This is all of the encoder conversion table.  It is NOT configured elsewhere.  Currently this is done for a 26-bit linear encoder and careful modification should be done for different number of bits.

### Motor_[1-4].pmh
This contains all of the motor setup for each motor.  There is some definition of Motor[9] at the bottom of Motor_1.pmh which is only for testing purposes and one can ignore or test with.

*WARNING*: Currntly motors are setup to use PFM and the need to be switched to +/-10V DAC according to the schematic before testing with a servo amplified.  Also, the tuning must be completely redone for this setup.

### gates.pmh
All hardware gates (umac cards) are setup here.  This includes the motor controller cards, BiSS-C cards, MACRO card.

### io_setup.pmh
In this file all of the definitions for IO on the IO cards are given.  This includes definitions for use in the PMAC code as well as (importantly) M-Variable mapping of these IO bits for use via EPICS.

### global_definitions.pmh
This file gives all of the global definitions used in the PMAC code.  Constants are defined with a leading 'k' always, e.g. kPI.  Motor home offsets are defined here as kM1OFFSET, etc.  They should only be written here.  There are absolute hard-coded gap, elevation, taper, and tilt limits for device safety.  All timers are defined here.  This is different from the call to subprog Timer().

All P-Variable definitions are done in this file.  The definitions are listed in PLC order and although some are used in multiple PLCs they are considered "owned" by the PLC they are listed under.  The numbering of these is also aimed to be "PLC consistant".  P600..699 for example correspond to PLC06.  One must ensure that global P-definitions start outside of the used range.  Some of these P variables are used to pass information to and from EPICS.  All defined P variables are of the form starting with "P_" e.g. P_BrakeTimeout.

Very importantly some user memory mapping is used to in this file to map BiSS bits and HomeFlags from hardware to pointers (there was no clean way to access those particular bits without bitshifts and masks, which makes code messy) and arrays of pointers.  These look like the following:
```
u.user:$3000 = Acc84E[0].Chan[0].SerialEncDataB
pLEncTimeout(1)->u.user:$3000.23.1
```

### Timers.pmc
This contains subprograms like "Timer" used generally for delay.  A nice feature over the old Turbo if you ask me.

### Kinematics_GapElev.pmh
All kinematic routines for the 3 coordinated motion types.

### PROG[##]_[name].pmh
Motion programs for the 3 types of coordinated motion.  These are fairly simple.  Note that these use the ABCU and Q71..74 with the position reporting PLC reporting back to Q81..84 as is needed by the EPICS DeltaTau driver for coordinate systems.

## PLCs
### PLC01 - Startup
This PLC is the startup PLC run once on reboot or power cycle.  It sets some default values and mode of operation.  Some of these settings may be overwritten by epics (e.g. Gap Speed, soft limits, etc).

### PLC02 - Movement In Progress
This PLC monitors the coordinate systems for a running (Coord[x].ProgRunning) and active program (Coord[x].ProgActive).  Desired velocity zero is also monitored for each motor (Motor[x].DesVelZero) as motion may happen outside of a motion program (e.g. following, homing).  This PLC sets the P_MovementInProgress internal P-variable for use in PLCs and Motion Programs.  Sys.ZeroVelSetPoint may need to be adjusted in order to use Motor[x].DesVelZero bits.

### PLC03 - Mode Change
This PLC controls the "mode" of the IVU.  In the typical mode Gap + Taper control will be separate from Elevation + Tilt control.  Other modes exist, including all combined and following modes where for example the downstream motors will follow the upstream motors (useful for homing for example).  One is not allowed to change modes if the emergency open gap is executing or if there is a movement in progress.  In these cases the request is ignored and one will need to issue another request once the correct conditions have been met.

### PLC04 - Emergency Open Gap
This PLC is generally meant to be used with a hardware input signal, but for now is implemented looking at a P-variable.  This PLC will check the signal, if it is detected it will stop all motion, change the move mode to kMoveModeOpenGapExecuting and attempt to open the gap with zero taper to either kMAXGAP (plus some offset to go past this) or to one of the limit switches.  Once this action is triggered the P_OpenGapExecuting flag is set to true which should prevent any other motion from the move request PLC.  Once P_OpenGapExecuting is set to true it must be reset manually or by a controller restart.  At the moment there is no override for this functionality.

### PL06 - Homing
This PLC will home 1 axis at a time.  The corresponding axis will be set to following mode and follow this axis.  In this mode, the home position as read on the linear encoder is read at the position of the home switch.  Once this is found, the offset values for the encoders must be set by hand in the PPMAC code (e.g. "#define kM1OFFSET 123456" in global_definitions.pmh).

During the homing process P_HomingInProgress is set to true and no other motion through PLC08 should be allowed.

This homing program is not yet complete.  The idea is only to record the linear encoder position when the switch is activated.  This captured value will be written displayed in EPICS/CSS.  The expert will then need to interpret this number in terms of kM1OFFSET (or other offset).  The reason for this is we are either using the switch is a reference to place a scale, or we are using the scale to find the switch.  Either part may be replaced in case of damage of failure.

### PLC07 - Beacon
This PLC monitors the AmpEnable status for each motor and trusts the CS and motor moving status calculated in PLC02.  Fault status are checked.  The beacon will illuminate in the following way:
* green - Motors and Drives Enabled
* yellow/orange flashing - ID in motion
* red - FAULT

### PLC08 - Move Request
This PLC considers Gap, Taper, Elevation, and Tilt move requests in the normal slow operation mode.  In this mode the amps will disable and brakes will engage after a user defined timeout (PLCXX).  Note that it is also possible to energize the motors (closed loop) and make move requests directly from the .VAL field of the epics motor record (useful for fast step-scanning).

### PLC09 - Girder Safety
This PLC will check soft limits for gap, elevation, taper, tilt.  Soft limits are defined in P-variables accessible from epics.  There are also hard-coded absolute limits as an extra safety measure.  These cannot be modified by epics.  If a gap/taper error is the P_GapError variable is marked, elevation/tilt error will mark P_ElevError, motors are killed (#1 and #2 for gap/taper, #3 and #4 for elevation/tilt errors).  These errors are latching and must be cleared if detected.  The typical course shoud this occur would be to adjust the soft-limit, clear the error, return to a good state, readjust the soft-limit.  There is a hard-coded "buffer" in kBUFFERUM included so that one may go to the limiting value without overshoot causing trouble.

This PLC also checks the Taper limit and kill switches.  These are treated differently from regular axis limit and kills since they do not beloing to one of the 4 input axes flags.  When one of these is encountered motion for #1 and #2 stops.  If the limit or kill disable is active motion for the corresponding switch will be allowed (i.e. one cannot simply back off a limit switch as with a normal axis).

### PLC10 - BISS Errors
This PLC monitors and counts all CRC, Timeout, Warning, and Errors for each BiSS-C linear encoder.  These are all reported to epics via p-variables.  The BiSS-C CRC, Timeout, and Error states for each encoder are latching errors.  Initially when one of these errors is encountered a killall signal is sent ("#\*k") killing all motors.  After this, a kill ("#nk") is continually sent to the motor with the associated encoder problem.  This stops and prevents motion on the motor with encoder errors while allowing motion on other motors.  Obviously coordinated motion with the affected motor will not be possible in this case, but it will allow for individual drive of other motors or use of coordinate systems which do not involve the bad motor/encoder.  If there is some encoder noise causing this to be a common stoppage some filtering can be applied at a later date.

To clear errors in this PLC there is a p-variable which when set to true clears all counts as well as clears all latching errors.  BiSS Warnings are counted, but ignored for motion stopping purposes.

### PLC18 - Position Reporting
This PLC calculates coordinate system positions and is used to report these to epics for the CS driver portion.  Since the values for the different coordinate systems are all the same this PLC copies them into each coordinate system (instead of writing multiple PLCs for the same thing).

## PPMAC Config files
### Global Includes/gates.pmh
Gates (cards) defined here.  BiSS-C global and channel control are defined here.  If you need to change the number of bits you must change it here as well as in the encoder conversion table and any motor settings related to it.

### Global Includes/EncoderTable.pmh
Encoder conversion table.  Linear absolute biss-c and rotary inputs defined here.  Default motor following also defined here (makes more sense to do it after all motor definitions).


## TODO
* Change from PFM output settings to +/-10V DAC mode.
* Update motor following for actual system in EncoderTable.pmh.
* Remove Motor #9 from Motor_1 file
* Check all parameter defaults in PLC01.
* Possibly define somewhere P_InterlockState.
* Consider using SDIS on the motor records exposed to beamline to avoid them setting the .VAL field of a coordinate system, which may bypass the open PLC.
* Check amp enables and how they get in/out of EPICS.  I am not sure this is correct.
