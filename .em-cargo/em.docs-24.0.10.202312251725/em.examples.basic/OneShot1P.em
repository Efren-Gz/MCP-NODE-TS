package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em$distro import McuC
from McuC import OneShotMilli

from em.mcu import Common

module OneShot1P

private:

    function handler: OneShotMilli.Handler

    var doneFlag: bool volatile = true

end

def em$run()
    Common.GlobalInterrupts.enable()
    for auto i = 0; i < 5; i++
        %%[d]
        AppLed.on()
        Common.BusyWait.wait(5000)
        AppLed.off()
        doneFlag = false
        OneShotMilli.enable(100, handler)
        while !doneFlag
            Common.Idle.exec()
        end
    end
end

def handler(arg)
    %%[c]
    doneFlag = true
end
