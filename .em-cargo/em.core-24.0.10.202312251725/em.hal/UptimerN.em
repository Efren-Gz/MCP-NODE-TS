package em.hal

import UptimerI

module UptimerN: UptimerI
    #   ^| Nil implementation of the UptimerI interface
end

def calibrate(secs256, ticks)
    return 0
end

def read()
    return null
end

def resetSync()
end

def trim()
    return 0
end
