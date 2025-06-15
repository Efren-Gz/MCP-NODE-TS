package em.examples.basic

from em$distro import BoardC
from BoardC import AppBut
from BoardC import AppLed
from BoardC import SysLed

from em.mcu import Common
from em.utils import FiberMgr

module Button3P

private:

    function onPressedCB: AppBut.OnPressedCB

end

def em$run()
    AppBut.onPressed(onPressedCB)
    FiberMgr.run()
end

def onPressedCB()
    %%[c]
    if AppBut.isPressed()
        SysLed.on()
        Common.BusyWait.wait(40000)  # 40ms
        SysLed.off()
    else
        AppLed.on()
        Common.BusyWait.wait(5000)  # 5ms
        AppLed.off()
    end
end
