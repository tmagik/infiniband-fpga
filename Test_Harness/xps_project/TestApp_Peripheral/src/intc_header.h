#define TESTAPP_GEN

/* $Id: intc_header.h,v 1.1.2.1 2008/02/12 13:58:05 svemula Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"

XStatus IntcSelfTestExample(Xuint16 DeviceId);
XStatus IntcInterruptSetup(XIntc *IntcInstancePtr, Xuint16 DeviceId);


