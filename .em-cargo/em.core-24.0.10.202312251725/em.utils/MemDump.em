package em.utils

module MemDump

    function print32(addr: ptr_t, count: uint8)

end

def print32(addr, count)
    auto p32 = <uint32*>addr
    while count--
        auto v = *p32
        printf "%08x: %08x\n", p32, v
        p32 += 1
    end
end
