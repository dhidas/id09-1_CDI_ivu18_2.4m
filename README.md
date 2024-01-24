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

## Coordinate Systems (CS)
It is assumed that typical usage will be gap and taper motion (without changing elevation or tilt).
* CS2 & PROG02 is used for gap+taper motion.
* CS3 & PROG03 is used for elevation+tilt motion.
* CS4 & PROG04 is used for combined motion gap+taper+elevation+tilt.

Position reporting for all coordinate systems is done in PLC18 to avoid duplicate code.
