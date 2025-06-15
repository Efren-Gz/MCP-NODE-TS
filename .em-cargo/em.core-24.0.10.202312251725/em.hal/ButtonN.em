package em.hal

import ButtonI

module ButtonN: ButtonI
    #   ^| Nil implementation of the ButtonI interface
end

def isPressed()
    return false
end

def onPressed(cb, minDurationMs, maxDurationMs)
end
