package em.mcu

from em.hal import PollerI

module Poller: PollerI

    proxy Impl: PollerI
    
    function pause(timeMs: uint16)

end

def pause(timeMs)
    Impl.poll(timeMs, 1, null)
end

def poll(rateMs, count, fxn)
    return Impl.poll(rateMs, count, fxn)
end
