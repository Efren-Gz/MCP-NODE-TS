package em.utils

from em.mcu import Common

module DebugPinAux

    type ToggleFxn: function()

    config pulseDelay: int32 = -1

    function pulse(toggleFxn: ToggleFxn)
    function mark(toggleFxn: ToggleFxn, k: uint8)

private:

    function delay()

end

def delay()
    ## TODO -- finer granularity
    Common.BusyWait.wait(<uint32>(-pulseDelay))
end

def pulse(toggleFxn)
    toggleFxn()
    delay()
    toggleFxn()
    delay()

end

def mark(toggleFxn, k)
    while k--
        pulse(toggleFxn)
    end
end
