package em.hal

import PollerI

module PollerN: PollerI
    #   ^| Nil implementation of the PollerI interface
end

def poll(rateMs, count, fxn)
    return 0
end
