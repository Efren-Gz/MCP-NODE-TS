package em.utils

from em.mcu import Common
from em.mcu import Copier

module HeapMem

    config baseAddr: addr_t
    config maxBytes: uint16

    function alloc(size: uint16): ptr_t
    function avail(): uint16
    function mark()
    function release()

private:

    var curTopPtr: uint32*
    var savTopPtr: uint32*

end

def em$startup()
    return if Common.Mcu.isWarm()
    curTopPtr = baseAddr
end

def alloc(size)
    auto ptr = curTopPtr
    auto wc = ((size + 3) & ~0x3) / 4
    curTopPtr += wc
    return ptr
end

def avail()
    return <uint16>((baseAddr + maxBytes) - <uint32>curTopPtr)
end

def mark()
    *curTopPtr = <uint32>savTopPtr
    savTopPtr = curTopPtr++
end

def release()
    fail if !savTopPtr
    curTopPtr = savTopPtr
    savTopPtr = <uint32*>*curTopPtr


end
