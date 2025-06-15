package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em$distro import McuC
from McuC import AppButEdge

from em.mcu import Common

module Button1P

private:

    function handler: AppButEdge.Handler

end

def em$construct()
    AppButEdge.setDetectHandlerH(handler)
end

def em$startup()
    AppButEdge.makeInput()
    AppButEdge.setInternalPullup(true)
    AppButEdge.setDetectFallingEdge()
end

def em$run()
    Common.GlobalInterrupts.enable()
    for ;;
        AppButEdge.enableDetect()
        Common.Idle.exec()
    end
end

def handler()
    %%[c]
    AppButEdge.clearDetect()
    AppLed.on()
    Common.BusyWait.wait(5000)
    AppLed.off()
end
