package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em.utils import AlarmMgr
from em.utils import FiberMgr

module Alarm1P

private:

    function blinkFB: FiberMgr.FiberBodyFxn

    config alarm: AlarmMgr.Alarm&
    config blinkF: FiberMgr.Fiber&

    var counter: uint32

end

def em$construct()
    blinkF = FiberMgr.createH(blinkFB)
    alarm = AlarmMgr.createH(blinkF)
end

def em$run()
    blinkF.post()
    FiberMgr.run()
end

def blinkFB(arg)
    %%[c]
    AppLed.wink(100)            # 100ms
    counter += 1
    if counter & 0x1
        alarm.wakeup(512)       # 2s
    else
        alarm.wakeup(192)       # 750ms
    end
end
