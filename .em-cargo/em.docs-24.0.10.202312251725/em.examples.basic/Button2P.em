package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em$distro import McuC
from McuC import AppButEdge

from em.mcu import Common

from em.utils import FiberMgr

module Button2P

private:

    function blinkFB: FiberMgr.FiberBodyFxn
    function handler: AppButEdge.Handler

    config blinkF: FiberMgr.Fiber&

end

def em$construct()
    AppButEdge.setDetectHandlerH(handler)
    blinkF = FiberMgr.createH(blinkFB)
end

def em$startup()
    AppButEdge.makeInput()
    AppButEdge.setInternalPullup(true)
    AppButEdge.setDetectFallingEdge()
end

def em$run()
    AppButEdge.enableDetect()
    FiberMgr.run()
end

def blinkFB(arg)
    %%[d]
    AppLed.on()
    Common.BusyWait.wait(5000)
    AppLed.off()
    AppButEdge.enableDetect()
end

def handler()
    %%[c]
    AppButEdge.clearDetect()
    blinkF.post()
end
