TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Install databases, templates & substitutions like this
DB += IVU18.db
#DB += ivu18.db
DB += motor.db
DB += plc18.db
DB += ppmacStatus.db
DB += ppmacStatusAxis.db
DB += ppmac_motorstatus.db
DB += ivu18_motorstatus.template
DB += ivu18_motorstatus.substitutions
#DB += $(PMAC)/db/pmacStatus.template ivu18.substitutions

DBD_INSTALLS += $(PMAC)/dbd/drvAsynPowerPMACPort.dbd

# Asyn in the next few lines may need to be modified for installation
#DB_INSTALLS += $(EPICS_BASE)/db/asynRecord.db
DBD_INSTALLS += $(ASYN)/dbd/asyn.dbd
DBD_INSTALLS += $(ASYN)/dbd/drvAsynIPPort.dbd
DB_INSTALLS += $(ASYN)/db/asynRecord.db

DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db
DB_INSTALLS += $(RECCASTER)/db/reccaster.db


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

