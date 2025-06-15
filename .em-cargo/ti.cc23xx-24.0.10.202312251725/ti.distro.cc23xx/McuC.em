package ti.distro.cc23xx

from ti.mcu.cc23xx import Regs     # force ordering

from ti.mcu.cc23xx import EdgeDetectGpioT {} as AppButEdge
from ti.mcu.cc23xx import GpioT {} as AppLedPin
from ti.mcu.cc23xx import GpioT {} as AppOutPin
from ti.mcu.cc23xx import GpioT {} as SysDbgA
from ti.mcu.cc23xx import GpioT {} as SysDbgB
from ti.mcu.cc23xx import GpioT {} as SysDbgC
from ti.mcu.cc23xx import GpioT {} as SysDbgD
from ti.mcu.cc23xx import GpioT {} as SysLedPin

from ti.mcu.cc23xx import ConsoleUart0 as AppOutUart
from ti.mcu.cc23xx import BusyWait
from ti.mcu.cc23xx import ExtFlashDisabler
from ti.mcu.cc23xx import GlobalInterrupts
from ti.mcu.cc23xx import Idle
from ti.mcu.cc23xx import IntrVec
from ti.mcu.cc23xx import Mcu
from ti.mcu.cc23xx import MsCounter
from ti.mcu.cc23xx import OneShotGpt3 as OneShotMilli
from ti.mcu.cc23xx import Uptimer
from ti.mcu.cc23xx import WakeupTimer

from em.mcu import Common
from em.mcu import CommonC

from em.utils import BoardInfo

export AppButEdge
export AppLedPin
export AppOutPin
export AppOutUart
export OneShotMilli
export SysDbgA
export SysDbgB
export SysDbgC
export SysDbgD
export SysLedPin
export Uptimer
export WakeupTimer

composite McuC

end

def em$preconfigure()
    auto brdRec = BoardInfo.readRecordH()
    auto pm = brdRec.pinMap
    AppButEdge.pin ?= pm.appBut
    AppLedPin.pin ?= pm.appLed
    AppOutPin.pin ?= pm.appOut
    AppOutUart.setBaudH(brdRec.baudRate)
    ExtFlashDisabler.em$used ?= brdRec.extFlashDisable
    ExtFlashDisabler.CLK_pin ?= pm.extFlashCLK
    ExtFlashDisabler.CS_pin ?= pm.extFlashCS
    ExtFlashDisabler.PICO_pin ?= pm.extFlashPICO
    ExtFlashDisabler.POCI_pin ?= pm.extFlashPOCI
    IntrVec.em$used ?= true
    Mcu.hasLfXtal ?= brdRec.lfXtalEnable
    Mcu.mclkFrequency ?= brdRec.clockFreq
    Regs.em$used ?= true
    SysDbgA.pin ?= pm.sysDbgA
    SysDbgB.pin ?= pm.sysDbgB
    SysDbgC.pin ?= pm.sysDbgC
    SysDbgD.pin ?= pm.sysDbgD
    SysLedPin.pin ?= pm.sysLed
end

def em$configure()
    Common.BusyWait ?= BusyWait
    Common.GlobalInterrupts ?= GlobalInterrupts
    Common.Idle ?= Idle
    Common.Mcu ?= Mcu
    Common.MsCounter ?= MsCounter
end