package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em.mcu import Common
from em.utils import FiberMgr

module FiberP

private:

    function blinkFB: FiberMgr.FiberBodyFxn

    config blinkF: FiberMgr.Fiber&

    var count: uint8 = 5

end

def em$construct()
    blinkF = FiberMgr.createH(blinkFB)
end

def em$run()
    blinkF.post()
    FiberMgr.run()
end

def blinkFB(arg)
    %%[d]
    halt if --count == 0
    AppLed.on()
    Common.BusyWait.wait(100000)
    AppLed.off()
    Common.BusyWait.wait(100000)
    blinkF.post()
end
