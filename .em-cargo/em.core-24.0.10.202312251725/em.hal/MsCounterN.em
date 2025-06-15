package em.hal

import MsCounterI

module MsCounterN: MsCounterI
    #   ^| Nil implementation of the MsCounterI interface
end

def start()
end

def stop()
    return 0
end
