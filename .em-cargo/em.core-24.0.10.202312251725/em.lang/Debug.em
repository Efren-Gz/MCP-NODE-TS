package em.lang

import DebugPinI

module Debug

    proxy Pin_a: DebugPinI
    proxy Pin_b: DebugPinI
    proxy Pin_c: DebugPinI
    proxy Pin_d: DebugPinI

    function getNumPins(): uint8
    function sleepEnter()
    function sleepLeave()
    function startup()

private:

end

def em$configure()
    em$used ?= true
end

def getNumPins()
    return 4
end

def sleepEnter()
    Pin_a.reset()
    Pin_b.reset()
    Pin_c.reset()
    Pin_d.reset()
end

def sleepLeave()
    startup()
end

def startup()
    Pin_a.startup()
    Pin_b.startup()
    Pin_c.startup()
    Pin_d.startup()
end
