package em.utils

# Fletcher-16 checksum

module Checksum

    type Obj: opaque
        function addData(buf: uint8*, len: uint16)
        function clear()
        function getSum8(): uint8
        function getSum16(): uint16
    end

private:

    def opaque Obj
        sum1: uint16
        sum2: uint16
    end

end

def Obj.addData(ptr, len)
    auto tl = <uint8>0
    while len
        tl = len >= 20 ? 20 : len
        len -= tl
        for ;;
            this.sum2 += this.sum1 += *ptr++
            tl -= 1
            break if tl == 0
        end
        this.sum1 = (this.sum1 & 0xFF) + (this.sum1 >> 8)
        this.sum2 = (this.sum2 & 0xFF) + (this.sum2 >> 8)
    end
    this.sum1 = (this.sum1 & 0xFF) + (this.sum1 >> 8)
    this.sum2 = (this.sum2 & 0xFF) + (this.sum2 >> 8)
#/*
    for i: uint16 = 0; i < len; i++
        this.sum1 += *ptr++
        this.sum1 -= 255 if this.sum1 >= 255;
        this.sum2 += this.sum1;
        this.sum2 -= 255 if this.sum2 >= 255;
    end
#*/    
end

def Obj.clear()
    this.sum1 = this.sum2 = 0xFF
end

def Obj.getSum8()
    return <uint8>(this.sum1 ^ this.sum2)
end

def Obj.getSum16()
    return this.sum2 << 8 | this.sum1
end
