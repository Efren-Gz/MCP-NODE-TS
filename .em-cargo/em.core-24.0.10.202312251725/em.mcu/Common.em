package em.mcu

from em.hal import BusyWaitI
from em.hal import GlobalInterruptsI
from em.hal import IdleI
from em.hal import McuI
from em.hal import MsCounterI
from em.hal import RandI
from em.hal import WatchdogI

module Common
        #   ^| collection of proxies implementing MCU abstractions
    proxy BusyWait: BusyWaitI
    proxy GlobalInterrupts: GlobalInterruptsI
    proxy Idle: IdleI 
    proxy Mcu: McuI    
    proxy MsCounter: MsCounterI    
    proxy Rand: RandI
    proxy Watchdog: WatchdogI

end
