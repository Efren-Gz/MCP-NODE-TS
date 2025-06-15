package em.hal

interface FlashI

    host function getSectorSizeH(): uint32
    host function getWriteChunkH(): uint32

    function erase(addr: addr_t, upto: addr_t = 0)
    function write(addr: addr_t, data: ptr_t, len: uint32): addr_t

end
