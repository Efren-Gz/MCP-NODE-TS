package em.hal

import GpioI

module GpioN: GpioI
    #   ^| Nil implementation of the GpioI interface
end

def set()
end

def clear()
end

def toggle()
end

def get()
    return false
end

def makeInput()
end

def isInput()
    return false
end

def makeOutput()
end

def isOutput()
    return false
end

def functionSelect(select)
end

def setInternalPullup(state)
end

def pinId()
    return 0
end

def reset()
end
