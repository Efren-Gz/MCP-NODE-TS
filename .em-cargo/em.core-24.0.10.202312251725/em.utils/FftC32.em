package em.utils

from em.lang import Math

module FftC32

    type Complex: class
        re: int16
        im: int16
        function get(): uint32
        function set(w: uint32)
    end

    config fftSize: uint16 = 128
    config shift: uint8 = 1

    function exec(buf: Complex[])

private:

    config N_WAVE: uint16
    config N_WAVE_LOG2: uint8

    config SINE_WAVE: int16[]

    function fixMul(a: int16, b: int16): int16

end

def em$construct()
    N_WAVE = fftSize
    N_WAVE_LOG2 = Math.log2(N_WAVE)
    auto numHalf = N_WAVE / 2
    auto numQtr = N_WAVE / 4
    SINE_WAVE.length = N_WAVE - numQtr
    auto rng = Math.PI / 2
    for auto i = 0; i < SINE_WAVE.length; i++
        if i <= numQtr
            auto sx = Math.sin((rng / numQtr) * i)
            SINE_WAVE[i] = Math.round(sx * 32767) >> shift
        elif i < numHalf
            SINE_WAVE[i] = SINE_WAVE[numHalf - i]
        else
            SINE_WAVE[i] = -(SINE_WAVE[i - numHalf])
        end
    end
end

def exec(buf)
    auto mr = 0
    for auto m = 1; m < fftSize; m++
        auto l = fftSize
        for ;;
            l >>= 1
            continue if mr + l > fftSize - 1
            break
        end
        mr = (mr & (l - 1)) + l
        continue if mr <= m
        auto t = buf[m].get()
        buf[m].set(buf[mr].get())
        buf[mr].set(t)
    end
    auto stage = 1
    auto sineStep = N_WAVE_LOG2 - 1
    while stage < fftSize
        auto twiddleStep = stage << 1
        for auto grp = 0; grp < stage; grp++
            auto idx = grp << sineStep
            auto wr = SINE_WAVE[idx + N_WAVE / 4]
            auto wi = -SINE_WAVE[idx]
            for auto i = grp; i < fftSize; i += twiddleStep
                auto j = i + stage
                auto fci = &buf[i]
                auto fcj = &buf[j]
                auto tr = fixMul(wr, fcj.re) - fixMul(wi, fcj.im)
                auto ti = fixMul(wr, fcj.im) + fixMul(wi, fcj.re)
                auto qr = fci.re >> shift
                auto qi = fci.im >> shift
                fcj.re = qr - tr
                fcj.im = qi - ti
                fci.re = qr + tr
                fci.im = qi + ti
            end
        end
        sineStep -= 1
        stage = twiddleStep
    end
end


def fixMul(a, b)
    auto c = (<int32>a * <int32>b) >> 14
    b = <int16>(<uint32>c & 0x01)
    a = <int16>((c >> 1) + b)
    return a
end

def Complex.get()
    return *(<uint32*>this)
end

def Complex.set(w)
    *(<uint32*>this) = w
end
