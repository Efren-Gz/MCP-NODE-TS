package em.hal

import WatchdogI

module WatchdogN: WatchdogI
    #   ^| Nil implementation of the WatchdogI interface
end

def didBite()
    return false
end

def disable()
end

def enable(secs, handler)
end

def pet()
end
