package em.mcu

from em.hal import BusyWaitN
from em.hal import GlobalInterruptsN
from em.hal import IdleN
from em.hal import McuN
from em.hal import MsCounterN
from em.hal import RandN
from em.hal import WatchdogN

from em.mcu import Common

composite CommonC

end

def em$configure()
    Common.BusyWait ?= BusyWaitN
    Common.GlobalInterrupts ?= GlobalInterruptsN
    Common.Idle ?= IdleN
    Common.Mcu ?= McuN
    Common.MsCounter ?= MsCounterN
    Common.Rand ?= RandN
    Common.Watchdog ?= WatchdogN
end