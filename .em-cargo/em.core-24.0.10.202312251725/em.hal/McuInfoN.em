package em.hal

import McuInfoI

module McuInfoN: McuInfoI
    #   ^| Nil implementation of the McuInfoI interface
end

def readBatMv()
    return 0
end

def readTempC()
    return 0
end
