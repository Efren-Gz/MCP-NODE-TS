package em.utils

from em.mcu import Common

module HeapStatic

    config baseAddr: addr_t
    config maxBytes: uint16
    
    host function allocH(size: uint16): ptr_t

    function getTopAddr(): addr_t
    host function getTopAddrH(): addr_t

private:

    const MASK: uint32 = 0x3
    config topAddr: addr_t
end

def em$construct()
    return if baseAddr || maxBytes == 0
    printf "*** HeapStatic:  baseAddr == 0\n"
    fail
end

def em$startup()
    return if Common.Mcu.isWarm()
    ^memset(<ptr_t>baseAddr, 0, topAddr - baseAddr) if topAddr && Common.Mcu.getResetCode() <= Common.Mcu.COLD_RESET
end

def allocH(size)
    topAddr = baseAddr if topAddr == 0
    auto p = <ptr_t>topAddr
    topAddr += size
    topAddr = (topAddr + MASK) & ~MASK
    return p if (topAddr - baseAddr) < maxBytes
    printf "*** HeapStatic.allocH: maxBytes = %d, size = %d\n", maxBytes, size
    fail
end

def getTopAddr()
    return topAddr
end

def getTopAddrH()
    return topAddr
end