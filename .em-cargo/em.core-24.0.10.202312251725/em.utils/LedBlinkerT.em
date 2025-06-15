package em.utils

template LedBlinkerT

end

def em$generateUnit(pn, un)
|->>>
package `pn`

from em.hal import LedI

from em.utils import LedBlinkerAux
from em.utils import LedBlinkerI

module `un`: LedBlinkerI

    proxy Led: LedI

end

def isOn()
    return Led.isOn()
end

def on()
    Led.on()
end

def off()
    Led.off()
end

def toggle()
    Led.toggle()
end

def blink(count, rateSecs, rateMs)
    LedBlinkerAux.setFxns(Led.on, Led.off)
    LedBlinkerAux.blink(count, rateSecs, rateMs)
end

def wink(onMs, offMs)
    LedBlinkerAux.setFxns(Led.on, Led.off)
    LedBlinkerAux.wink(onMs, offMs)
end
|-<<<
end