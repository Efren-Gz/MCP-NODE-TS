package em.utils

from em.lang import Console

module Formatter

    function print(fmt: string, a1: iarg_t = 0, a2: iarg_t = 0, a3: iarg_t = 0, a4: iarg_t = 0, a5: iarg_t = 0, a6: iarg_t = 0)
    function puts(s: string)

private:

    const OUTMAX: uint8 = ((32 + 2) / 3) + 5

    function c2d(c: char): uint8
    function formatNum(buf: char*, num: uint32, base: uint8, pad: char, len: uint8): char*
    function isDigit(c: char): bool

    config hexDigs: string = "0123456789abcdef"

end

def c2d(c)
    return c - '0'
end

def formatNum(buf, num, base, pad, len)
    auto cnt = len
    *(--buf) = 0
    for ;;
        *(--buf) = hexDigs[<uint8> (num % base)]
        num /= base
        break if len > 0 && --cnt == 0
        break if num == 0
    end
    while cnt-- > 0
        *(--buf) = pad
    end
    return buf
end

def isDigit(c)
    return c >= '0' && c <= '9'
end

def print(fmt, a1, a2, a3, a4, a5, a6)
    var ch: char
    var buf: char[OUTMAX]
    var args: iarg_t[6]
    var argp: iarg_t* = &args[0]
    args[0] = a1
    args[1] = a2
    args[2] = a3
    args[3] = a4
    args[4] = a5
    args[5] = a6
    while (ch = *fmt++) != 0
        auto pad = ' '
        auto len = 0
        if (ch != '%') 
            Console.wrC(ch)
            continue
        end
        ch = *fmt++
        if ch == '0'
            pad = '0'
            ch = *fmt++
            end
        while isDigit(ch)
            len = (len * 10) + c2d(ch)
            ch = *fmt++
            end
        var out: char*
        if ch == 'd'
            var dn: int32 = <int32> *argp++
            if dn < 0
                Console.wrC('-')
                dn = -dn
            end
            out = formatNum(&buf[OUTMAX], <uint32> dn, 10, pad, len)
        elif ch == 'x' 
            var xn: uint32 = <uint32> *argp++
            out = formatNum(&buf[OUTMAX], xn, 16, pad, len)
        elif ch == 's'
            out = <char*> *argp++
        else
            Console.wrC(ch == 'c' ? <char> *argp++ : ch)
            continue
        end
        puts(<string>out)
    end
end

def puts(s)
    var cp: char* = <char*>s
    var ch: char
    while (ch = *cp++) != 0
        Console.wrC(ch)
    end
end