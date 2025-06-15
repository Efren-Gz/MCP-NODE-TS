package ti.mcu.cc23xx

import Rtc

from em.hal import UptimerI

module Uptimer: UptimerI

private:

    var curTime: Time

end

def calibrate(secs256, ticks)
    ## TODO -- implement
    return 0
end

def read()
    curTime.secs = Rtc.getRaw(&curTime.subs)
    return curTime
end

def resetSync()
    ## TODO -- implement
end

def trim()
    ## TODO -- implement
    return 0
end
