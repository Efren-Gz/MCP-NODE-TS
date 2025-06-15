package em.utils

module Crc16

    type Obj: opaque
        function addByte(b: uint8): uint8
        function addData(src: uint8*, len: uint8)
        function getSum(): uint16
        function getSumLsb(): uint8
        function getSumMsb(): uint8
        function init()
    end

    host function createH(): Obj&

private:

    const POLY: uint16 = 0x8005

    def opaque Obj
        sum: uint16
        function update(b: uint8)
    end

end

def createH()
    return new<Obj>
end

def Obj.addByte(b)
    this.update(b)
    return b
end

def Obj.addData(src, len)
    while len--
        this.update(*src++)
    end
end

def Obj.getSum()
    return this.sum
end

def Obj.getSumLsb()
    return <uint8>(this.sum & 0xFF)
end

def Obj.getSumMsb()
    return <uint8>(this.sum >> 8)
end

def Obj.init()
    this.sum = 0xFFFF
end

def Obj.update(b)
    auto tot = this.sum
    for auto i = 0; i < 8; i++
        if ((tot & 0x8000) >> 8) ^ (b & 0x80)
            tot = (tot << 1) ^ POLY
        else
            tot = (tot << 1)
        end
        b <<= 1
    end
    this.sum = tot
end

