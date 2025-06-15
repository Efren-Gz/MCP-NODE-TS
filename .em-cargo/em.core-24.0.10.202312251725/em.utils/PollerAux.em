package em.utils

from em.hal import OneShotMilliI
from em.hal import PollerI

from em.mcu import Common

module PollerAux: PollerI

    proxy OneShot: OneShotMilliI

    config pauseOnly: bool = false

private:

    function handler: OneShot.Handler
    function pause(msecs: uint32)

    var doneFlag: bool volatile

end

def handler(arg)
    doneFlag = true
end

def pause(msecs)
    return if msecs == 0
    doneFlag = false
    OneShot.enable(msecs, handler, null)
    while !doneFlag
        Common.Idle.exec()
    end
end

def poll(rate, count, fxn)
    if pauseOnly
        pause(rate)
        return 1
    else
        count = 0 if rate == 0
        while count
            pause(rate)
            count -= 1
            break if fxn && fxn()
        end
        return count        
    end
end
