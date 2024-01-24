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
