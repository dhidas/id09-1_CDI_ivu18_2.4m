TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Use typed rset structure (see 3.16.1 release notes)
USR_CPPFLAGS += -DUSE_TYPED_RSET


# Build an IOC support library
#LIBRARY_IOC += IVU18Support


# Link locally-provided code into the support library,
# rather than directly into the IOC application, that
# causes problems on Windows DLL builds
#IVU18Support_SRCS += dbSubExample.c

#IVU18Support_LIBS += $(EPICS_BASE_IOC_LIBS)

# Auto-generate a header file containing a version string.
# Version comes from the VCS if available, else date+time.
#GENVERSION = IVU18Version.h
# Macro name
#GENVERSIONMACRO = IVU18VERSION

# Build the IOC application
PROD_IOC = IVU18

# IVU18.dbd will be created and installed
DBD += IVU18.dbd

PPMAC=$(SUPPORT)/pmac-2-6-4b3/pmacApp/powerPmacAsynPortSrc

# IVU18.dbd will include these files:
IVU18_DBD += base.dbd
#IVU18_DBD += $(TOP)/pmacApp/powerPmacAsynPortSrc/drvAsynPowerPMACPort.dbd
IVU18_DBD += asyn.dbd
IVU18_DBD += drvAsynIPPort.dbd
#IVU18_DBD += drvAsynPowerPMACPort.dbd
IVU18_DBD += $(PPMAC)/drvAsynPowerPMACPort.dbd
IVU18_DBD += motorSupport.dbd
IVU18_DBD += devSoftMotor.dbd
#IVU18_DBD += pmacAsynMotor.dbd
IVU18_DBD += pmacAsynMotorPort.dbd
IVU18_DBD += pmacAsynIPPort.dbd
IVU18_DBD += asSupport.dbd
IVU18_DBD += busySupport.dbd
IVU18_DBD += calcSupport.dbd
IVU18_DBD += system.dbd
IVU18_DBD += devIocStats.dbd
IVU18_DBD += caPutLog.dbd
IVU18_DBD += ether_ip.dbd
IVU18_DBD += stream.dbd
IVU18_DBD += reccaster.dbd





# IVU18_registerRecordDeviceDriver.cpp derives from IVU18.dbd
IVU18_SRCS += IVU18_registerRecordDeviceDriver.cpp
IVU18_LIBS += calc
IVU18_LIBS += busy
IVU18_LIBS += pmacAsynMotorPort
IVU18_LIBS += pmacAsynIPPort
IVU18_LIBS += softMotor
IVU18_LIBS += motor
#IVU18_LIBS += pmacAsynMotor
IVU18_LIBS += powerPmacAsynPort
IVU18_LIBS += asyn
IVU18_LIBS += autosave
IVU18_LIBS += stream
IVU18_LIBS += devIocStats
IVU18_LIBS += caPutLog
IVU18_LIBS += ether_ip
IVU18_LIBS += reccaster

IVU18_LIBS += $(EPICS_BASE_IOC_LIBS)

# Build the main IOC entry point where needed
IVU18_SRCS_DEFAULT += IVU18Main.cpp

# Link in the code from our support library
#IVU18_LIBS += IVU18Support




include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

# Explicit dependency needed for generated header file
#devIVU18Version$(DEP): $(COMMON_DIR)/$(GENVERSION)
