# id09-1_CDI_ivu18_2.4m

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




## PLCs
### PLC01 - Startup
This PLC is the startup PLC run once on reboot or power cycle.  It sets some default values and mode of operation.  Some of these settings may be overwritten by epics (e.g. Gap Speed, soft limits, etc).

### PLC02 - Movement In Progress
This PLC monitors the coordinate systems for a running (Coord[x].ProgRunning) and active program (Coord[x].ProgActive).  Desired velocity zero is also monitored for each motor (Motor[x].DesVelZero) as motion may happen outside of a motion program (e.g. following, homing).  This PLC sets the P_MovementInProgress internal P-variable for use in PLCs and Motion Programs.  Sys.ZeroVelSetPoint may need to be adjusted in order to use Motor[x].DesVelZero bits.

### PLC03 - Mode Change
This PLC controls the "mode" of the IVU.  In the typical mode Gap + Taper control will be separate from Elevation + Tilt control.  Other modes exist, including all combined and following modes where for example the downstream motors will follow the upstream motors (useful for homing for example).  One is not allowed to change modes if the emergency open gap is executing or if there is a movement in progress.  In these cases the request is ignored and one will need to issue another request once the correct conditions have been met.

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
* Modify pEnc and pEnc2 on all motors to allow biss-c linear for position and rotary for velocity.
* Update motor following for actual system (change from IVFC system) in EncoderTable.pmh.
* Remove Motor #9 from Motor_1 file
* Consider changing enc loss from (in all motors):

  Motor[1].EncLossBit=28
  Motor[1].EncLossLevel=1
  Motor[1].EncLossLimit=0
  Motor[1].pEncLoss=Acc24E3[0].Chan[0].Status.a
  to
  Acc84E[0].Chan[0].SerialEncDataB.a
  Motor[1].EncLossBit=31
  Motor[1].EncLossLevel=1
  Motor[1].EncLossLimit=4

* Figure out evquivalent of "Motor[1].pEncCtrl=Acc24E3[0].Chan[0].InCtrl.a" for Acc84E (biss-c)
* Check all parameter defaults in PLC01.  Reset for IVU from IVFS values.
