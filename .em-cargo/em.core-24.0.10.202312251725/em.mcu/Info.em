package em.mcu

from em.hal import McuInfoI

module Info: McuInfoI

    proxy Impl: McuInfoI

end

def readBatMv()
    return Impl.readBatMv()
end

def readTempC()
    return Impl.readTempC()
end
