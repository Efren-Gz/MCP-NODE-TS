package ti.mcu.cc23xx

from em.hal import IdleI
from em.lang import Debug

module Idle: IdleI

    type Callback: function()

    host function addSleepEnterCbH(cb: Callback) 
    host function addSleepLeaveCbH(cb: Callback) 

    function doSleep()
    function doWait()

    function setWaitOnly(val: bool)

private:

    config sleepEnterCbTab: Callback[..]
    config sleepLeaveCbTab: Callback[..]

    var waitOnly: bool

end

def em$startup()
    %%[b+]
    ^^HWREG(PMCTL_BASE + PMCTL_O_VDDRCTL)^^ = ^PMCTL_VDDRCTL_SELECT     # LDO
    ^^HWREG(EVTULL_BASE + EVTULL_O_WKUPMASK)^^ = ^EVTULL_WKUPMASK_AON_RTC_COMB | ^EVTULL_WKUPMASK_AON_IOC_COMB
end

def addSleepEnterCbH(cb)
    sleepEnterCbTab[sleepEnterCbTab.length++] = cb
end

def addSleepLeaveCbH(cb)
    sleepLeaveCbTab[sleepLeaveCbTab.length++] = cb
end

def doSleep()
    for cb in sleepEnterCbTab
        cb()
    end
    %%[b:2]
    %%[b-]
    Debug.sleepEnter()
    ^^HWREG(CKMD_BASE + CKMD_O_LDOCTL)^^ = 0x0
    ^^__set_PRIMASK(1)^^
    ^^HapiEnterStandby(NULL)^^
    Debug.sleepLeave()
    %%[b+]
    for cb in sleepLeaveCbTab
        cb()
    end
    ^^__set_PRIMASK(0)^^
end

def doWait()
    %%[b:1]
    %%[b-]
    ^^__set_PRIMASK(1)^^
    ^^asm("wfi")^^
    %%[b+]
    ^^__set_PRIMASK(0)^^
end


def exec()
    if waitOnly
        doWait()
    else
        doSleep()
    end
end

def setWaitOnly(val)
    waitOnly = val
end

def wakeup()
    ## TODO -- implement
end
