package em.utils

template DebugPinT

end

def em$generateUnit(pn, un)
|->>>
package `pn`

from em.utils import DebugPinAux as Aux
from em.lang import DebugPinI
from em.hal import GpioI

module `un`: DebugPinI

    proxy Pin: GpioI

end

def clear()
    Pin.set()
end

def get()
    return Pin.get() != 0
end

def set()
    Pin.clear()
end

def toggle()
    Pin.toggle()
end

def pulse()
    Aux.pulse(<Aux.ToggleFxn>toggle)
end

def mark(k)
    Aux.mark(<Aux.ToggleFxn>toggle, k)
end

def reset()
    Pin.reset()
end

def startup()
    Pin.makeOutput()
    Pin.set()
end
|-<<<
end
