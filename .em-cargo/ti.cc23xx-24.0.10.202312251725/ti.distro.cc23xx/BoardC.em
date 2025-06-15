package ti.distro.cc23xx

from em.lang import Atom                    # force ordering

import McuC
from McuC import AppButEdge
from McuC import AppLedPin
from McuC import AppOutPin
from McuC import AppOutUart
from McuC import SysDbgA
from McuC import SysDbgB
from McuC import SysDbgC
from McuC import SysDbgD
from McuC import SysLedPin
from McuC import OneShotMilli
from McuC import Uptimer
from McuC import WakeupTimer

from em.lang import Console
from em.lang import Debug

from em.mcu import ConsoleUart
from em.mcu import Poller

from em.utils import AlarmMgr
from em.utils import BoardController
from em.utils import BoardInfo
from em.utils import EpochTime
from em.utils import FormattingConsole
from em.utils import PollerAux

from em.utils import DebugPinT {} as DbgA
from em.utils import DebugPinT {} as DbgB
from em.utils import DebugPinT {} as DbgC
from em.utils import DebugPinT {} as DbgD

from em.utils import LedT {} as AppLed
from em.utils import LedT {} as SysLed

from em.utils import ButtonT {} as AppBut

export AppBut
export AppLed
export SysLed

composite BoardC

end

def em$configure()
    auto brdRec = BoardInfo.readRecordH()
    auto pm = brdRec.pinMap
    AlarmMgr.WakeupTimer ?= WakeupTimer
    AppBut.Edge ?= AppButEdge
    AppLed.activeLow ?= brdRec.activeLowLeds
    AppLed.em$used ?= true
    AppLed.Pin ?= AppLedPin
    AppOutUart.TxPin ?= AppOutPin
    BoardController.em$used ?= true
    BoardController.Led ?= SysLed
    Console.em$used ?= true
    Console.Provider ?= FormattingConsole
    ConsoleUart.Impl ?= AppOutUart
    DbgA.Pin ?= SysDbgA
    DbgB.Pin ?= SysDbgB
    DbgC.Pin ?= SysDbgC
    DbgD.Pin ?= SysDbgD
    Debug.Pin_a ?= DbgA
    Debug.Pin_b ?= DbgB
    Debug.Pin_c ?= DbgC
    Debug.Pin_d ?= DbgD
    EpochTime.Uptimer ?= Uptimer
    Poller.Impl ?= PollerAux
    PollerAux.OneShot ?= OneShotMilli
    SysLed.activeLow ?= brdRec.activeLowLeds
    SysLed.em$used ?= true
    SysLed.Pin ?= SysLedPin
end
