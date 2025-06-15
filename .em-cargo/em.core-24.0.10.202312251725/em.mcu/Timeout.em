package em.mcu

from em.hal import TimeoutI

module Timeout: TimeoutI

    proxy Impl: TimeoutI

end

def active()
    return Impl.active()
end

def cancel()
    Impl.cancel()
end

def set(msecs)
    Impl.set(msecs)
end
