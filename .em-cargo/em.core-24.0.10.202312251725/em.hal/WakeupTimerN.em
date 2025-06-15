package em.hal

import WakeupTimerI

module WakeupTimerN: WakeupTimerI
    #   ^| Nil implementation of the WakeupTimerI interface
end

def disable()
end

def enable(thresh, handler)
end

def secs256ToTicks(secs256)
    return 0
end

def ticksToThresh(ticks)
    return 0
end

def timeToTicks(secs, subs)
    return 0
end
