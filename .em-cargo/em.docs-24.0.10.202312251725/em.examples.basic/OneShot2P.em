package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em$distro import McuC
from McuC import OneShotMilli

from em.mcu import Common
from em.utils import FiberMgr

module OneShot2P

private:

    function blinkFB: FiberMgr.FiberBodyFxn
    function handler: OneShotMilli.Handler

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
    AppLed.on()
    Common.BusyWait.wait(5000)
    AppLed.off()
    halt if --count == 0
    OneShotMilli.enable(100, handler, null)
end

def handler(arg)
    %%[c]
    blinkF.post()
end
