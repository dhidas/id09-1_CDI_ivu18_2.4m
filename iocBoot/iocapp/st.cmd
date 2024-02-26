#!../../bin/linux-x86_64/IVU18

#- You may have to change IVU18 to something else
#- everywhere it appears in this file

< envPaths

epicsEnvSet("ENGINEER", "Dean Andrew Hidas is not an engineer. <dhidas@bnl.gov>")
#epicsEnvSet("PMACUTIL", "/usr/share/epics-pmacutil-dev")
epicsEnvSet("PMAC1_IP", "192.168.0.200")
#epicsEnvSet("PLC_IP","10.0.160.137")
epicsEnvSet("sys", "SR:C09-ID:G1")
epicsEnvSet("dev", "IVU18:1")
epicsEnvSet("LOCATION",$(HOSTNAME))
epicsEnvSet("STREAM_PROTOCOL_PATH", "/usr/lib/epics/protocol:$(TOP)/proto")

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/IVU18.dbd"
IVU18_registerRecordDeviceDriver pdbbase


#- Set this to see messages from mySub
#var mySubDebug 1

#- Run this to trace the stages of iocInit
#traceIocInit

# Create SSH Port (PortName, IPAddress, Username, Password, Priority, DisableAutoConnect, noProcessEos)
drvAsynPowerPMACPortConfigure("BRICK1port", $(PMAC1_IP), "root", "deltatau", "0", "0", "0")

# Configure Model 3 Controller Driver (ControlerPort, LowLevelDriverPort, Address, Axes, MovingPoll, IdlePoll)
pmacCreateController("Brick", "BRICK1port", 0, 4, 100, 1000)
# Configure Model 3 Axes Driver (Controler Port, Axis Count)
pmacCreateAxes("Brick", 4)
#
pmacDisableLimitsCheck("Brick", 1, 1)
pmacDisableLimitsCheck("Brick", 2, 1)
pmacDisableLimitsCheck("Brick", 3, 1)
pmacDisableLimitsCheck("Brick", 4, 1)
#
#dbLoadTemplate("ivu18.substitutions")


# Create CS (ControllerPort, Addr, CSNumber, CSRef, Prog)
# Gap: Coordinate System 2 | PROG 2
#pmacAsynCoordCreate("BRICK1port", 0, 2, 0, 2)

# Configure CS (PortName, DriverName, CSRef, NAxes)
#drvAsynMotorConfigure("BrickCS2", "pmacAsynCoord", 0, 4)

# Create CS (CSPortName, ControllerPort, CSNumber, ProgramNumber)
pmacCreateCS("BrickCS2", "Brick", 2, 2)
pmacCreateCS("BrickCS3", "Brick", 3, 3)
# Configure Model 3 CS Axes Driver (CSPortName, CSAxisCount)
pmacCreateCSAxes("BrickCS2", 2)
pmacCreateCSAxes("BrickCS3", 4)

pmacSetCoordStepsPerUnit("BrickCS2", 1, 1000)
pmacSetCoordStepsPerUnit("BrickCS2", 2, 1000)
pmacSetCoordStepsPerUnit("BrickCS3", 3, 1000)
pmacSetCoordStepsPerUnit("BrickCS3", 4, 1000)

## Load record instances
#dbLoadTemplate "db/user.substitutions"
dbLoadRecords("db/IVU18.db", "SYS=$(sys),DEV=$(dev),PORT=BRICK1port")
#dbLoadRecords("db/ivu18.db", "SYS=$(sys),DEV=$(dev)")


dbLoadTemplate("db/ivu18_motorstatus.substitutions", "SYS=$(sys),DEV=$(dev),PORT=BRICK1port")

#{P,  M,  MOTOR,  PORT,  ADDR,  DESC,  DTYP,  MRES,  EGU,  PREC,  ALIAS  }
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-Ax:GU}-Mtr,MOTOR=Brick,PORT=BRICK1port,ADDR=1,DESC=asd,DTYP=asynMotor,MRES=.24399997950400172,EGU=um,PREC=1")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-Ax:GD}-Mtr,MOTOR=Brick,PORT=BRICK1port,ADDR=2,DESC=asd,DTYP=asynMotor,MRES=.24399997950400172,EGU=um,PREC=1")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-Ax:EU}-Mtr,MOTOR=Brick,PORT=BRICK1port,ADDR=3,DESC=asd,DTYP=asynMotor,MRES=.24399997950400172,EGU=um,PREC=1")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-Ax:ED}-Mtr,MOTOR=Brick,PORT=BRICK1port,ADDR=4,DESC=asd,DTYP=asynMotor,MRES=.24399997950400172,EGU=um,PREC=1")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-CS2:Gap}-Mtr,MOTOR=BrickCS2,PORT=BRICK1port,ADDR=1,DESC=asd,DTYP=asynMotor,MRES=0.001,EGU=um,PREC=2")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-CS2:Taper}-Mtr,MOTOR=BrickCS2,PORT=BRICK1port,ADDR=2,DESC=asd,DTYP=asynMotor,MRES=0.001,EGU=um,PREC=2")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-CS3:Elev}-Mtr,MOTOR=BrickCS3,PORT=BRICK1port,ADDR=3,DESC=asd,DTYP=asynMotor,MRES=0.001,EGU=um,PREC=2")
dbLoadRecords("db/motor.db", "P=$(sys),M={$(dev)-CS3:Tilt}-Mtr,MOTOR=BrickCS3,PORT=BRICK1port,ADDR=4,DESC=asd,DTYP=asynMotor,MRES=0.001,EGU=um,PREC=2")
dbLoadRecords("db/ppmacStatus.db", "SYS=$(sys),PMAC=$(dev),NAXES=8,PORT=BRICK1port,PLC=5,VERSION=0")
dbLoadRecords("db/ppmacStatusAxis.db", "SYS=$(sys),DEV={$(dev)-Ax:1},AXIS=1,PORT=BRICK1port")
dbLoadRecords("db/ppmacStatusAxis.db", "SYS=$(sys),DEV={$(dev)-Ax:2},AXIS=2,PORT=BRICK1port")
dbLoadRecords("db/ppmacStatusAxis.db", "SYS=$(sys),DEV={$(dev)-Ax:3},AXIS=3,PORT=BRICK1port")
dbLoadRecords("db/ppmacStatusAxis.db", "SYS=$(sys),DEV={$(dev)-Ax:4},AXIS=4,PORT=BRICK1port")
dbLoadRecords("db/ppmac_motorstatus.db", "SYS=$(sys),DEV={$(dev)-Ax:GU},MOTOR=Brick,PORT=BRICK1port,AXIS=1,DESC=Gap Upstream")
dbLoadRecords("db/ppmac_motorstatus.db", "SYS=$(sys),DEV={$(dev)-Ax:GD},MOTOR=Brick,PORT=BRICK1port,AXIS=2,DESC=Gap Downstream")
dbLoadRecords("db/ppmac_motorstatus.db", "SYS=$(sys),DEV={$(dev)-Ax:EU},MOTOR=Brick,PORT=BRICK1port,AXIS=3,DESC=Elevation Upstream")
dbLoadRecords("db/ppmac_motorstatus.db", "SYS=$(sys),DEV={$(dev)-Ax:ED},MOTOR=Brick,PORT=BRICK1port,AXIS=4,DESC=Elevation Downstream")

dbLoadRecords("db/asynRecord.db","P=$(sys),R={$(dev)}Asyn,ADDR=1,PORT=BRICK1port,IMAX=128,OMAX=128")




cd "${TOP}/iocBoot/${IOC}"
iocInit

## Start any sequence programs
#seq sncExample, "user=dhidas"

dbl > records.txt
