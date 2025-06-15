package em.build.misc

module AppImage

    type Desc: struct
        marker: uint32
        buildTime: uint32
        bootSha: uint32
        mainSha: uint32
        codeLoad: addr_t
        codeAddr: addr_t
        bssAddr: addr_t
        bssSize: uint32
        dataLoad: addr_t
        dataAddr: addr_t
        dataSize: uint32
    end

    config descAddr: addr_t = 0x1000
    config stagingAddr: addr_t = 0x10000

    function getDesc(): Desc&
    function getStagingSize(): uint16

private:

    config defaultDesc: Desc

end

def em$generateCode(prefix)
    |-> extern "C" unsigned int __boot_flag__;
end

def getDesc()
    return <bool>^^&__boot_flag__^^ ? <Desc&>descAddr: <Desc&>&defaultDesc
end

def getStagingSize()
    auto w = *<uint32*>stagingAddr
    return <bool>^^&__boot_flag__^^ && (w & 0xffff) == 0xfeca ? <uint16>(w >> 16) : 0
end
