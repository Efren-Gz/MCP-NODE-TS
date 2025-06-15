package em.lang

import ConsoleProviderI

module Console

    proxy Provider: ConsoleProviderI

    config noPrint: bool

    function print(fmt: string, a1: iarg_t = 0, a2: iarg_t = 0, a3: iarg_t = 0, a4: iarg_t = 0, a5: iarg_t = 0, a6: iarg_t = 0)

    function wrC(data: char)
    function wrN(data: num_t)
    function wrP(data: ptr_t)
    
    function wrT(data: string)
    
    function wrIA(data: iarg_t)
    function wrUA(data: uarg_t)
    
    function wrI8(data: int8)
    function wrI16(data: int16)
    function wrI32(data: int32)
    
    function wrU8(data: uint8)
    function wrU16(data: uint16)
    function wrU32(data: uint32)
    
end

def em$generateCode(prefix)
    |-> #define em$print em_lang_Console::print
end

def print(fmt, a1, a2, a3, a4, a5, a6)
    if !noPrint
        Provider.print(fmt, a1, a2, a3, a4, a5, a6)
    end
end

def wrC(data)
    Provider.put(data)
end

def wrN(data)
    Provider.put(0x8F)
    auto ba = <uint8[]>(&data)
    for auto i = 0; i < sizeof<num_t>; i++
        Provider.put(ba[i])
    end
    Provider.flush()
end

def wrP(data)
    wrU32(<uint32>data)
end

def wrT(data)
    Provider.put(0x80)
    auto cp = <char*>data
    for ;;
        auto ch = *cp++
        wrC(ch)
        return if ch == 0      
    end
end

def wrIA(data)
    wrU16(<uint16>data)
end

def wrUA(data)
    wrU16(<uint16>data)
end

def wrI8(data)
    wrU8(<uint8>data)
end

def wrI16(data)
    wrU16(<uint16>data)
end

def wrI32(data)
    wrU32(<uint32>data)
end

def wrU8(data)
    Provider.put(0x81)
    Provider.put(data)
    Provider.flush()
end

def wrU16(data)
    Provider.put(0x82)
    auto b = <uint8> ((data >> 8) & 0xFF)
    Provider.put(b)
    b = <uint8> ((data >> 0) & 0xFF)
    Provider.put(b)
    Provider.flush()
end

def wrU32(data)
    Provider.put(0x84)
    auto b = <uint8> ((data >> 24) & 0xFF)
    Provider.put(b)
    b = <uint8> ((data >> 16) & 0xFF)
    Provider.put(b)
    b = <uint8> ((data >> 8) & 0xFF)
    Provider.put(b)
    b = <uint8> ((data >> 0) & 0xFF)
    Provider.put(b)
    Provider.flush()
end
