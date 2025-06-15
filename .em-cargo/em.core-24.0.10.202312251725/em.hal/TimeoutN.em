package em.hal

import TimeoutI

module TimeoutN: TimeoutI
    #   ^| Nil implementation of the TimeoutI interface
end

def active()
    return false
end

def cancel()
end

def set(msecs)
end
