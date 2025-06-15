package em.hal

import LedI

module LedN: LedI
    #   ^| Nil implementation of the LedI interface
end

def isOn()
    return false
end

def on()
end

def off()
end

def toggle()
end

def wink(usecs)
end
