package em.utils

from em.lang import Math

module FftQ15

    config fftSize: uint16 = 128
    config shift: uint8 = 1

    function exec(fr: int16[], fi: int16[])

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

def exec(fr, fi)
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
        auto tr = fr[m]
        fr[m] = fr[mr]
        fr[mr] = tr
        auto ti = fi[m]
        fi[m] = fi[mr]
        fi[mr] = ti
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
                auto tr = fixMul(wr, fr[j]) - fixMul(wi, fi[j])
                auto ti = fixMul(wr, fi[j]) + fixMul(wi, fr[j])
                auto qr = fr[i] >> shift
                auto qi = fi[i] >> shift
                fr[j] = qr - tr
                fi[j] = qi - ti
                fr[i] = qr + tr
                fi[i] = qi + ti
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
