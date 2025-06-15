package em.hal

import FlashI

module FlashN: FlashI
    #   ^| Nil implementation of the FlashI interface
end

def getSectorSizeH()
    return 0
end

def getWriteChunkH()
    return 0
end

def erase(addr, upto)
end

def write(addr, data, len)
    return 0
end
