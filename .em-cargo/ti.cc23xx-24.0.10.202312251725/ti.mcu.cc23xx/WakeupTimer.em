package ti.mcu.cc23xx

from em.hal import WakeupTimerI

import Rtc

module WakeupTimer: WakeupTimerI

end

def disable()
    Rtc.disable()
end

def enable(secs256, handler)
    Rtc.enable(secs256, <Rtc.Handler>handler)
end

def secs256ToTicks(secs256)
    return secs256 << 8
end

def ticksToThresh(ticks)
    return Rtc.toThresh(ticks)
end

def timeToTicks(secs, subs)
    return (secs << 16) | (subs >> 16)
end
