package em.utils

module BufPrint

    config enabled: bool

    function bswap(ptr: ptr_t, cnt: uint16, lab: string = null)
    function bytes(ptr: ptr_t, cnt: uint16, lab: string = null)
    function words(ptr: ptr_t, cnt: uint16, lab: string = null)

private:

    function label(lab: string)

end

def bswap(ptr, cnt, lab)
    if enabled
        label(lab) if lab
        printf "["
        auto pb = <uint8*>ptr
        auto wc = ((cnt + 0x3) & ~0x3) / 4
        auto sep = ""
        while wc--
            printf "%s", sep
            sep = ", "
            var buf: uint8[4]
            buf[0] = *pb++
            buf[1] = *pb++
            buf[2] = *pb++
            buf[3] = *pb++
            auto nb = cnt >= 4 ? 4 : cnt
            cnt -= nb
            auto idx = 3
            while nb--
                printf "%02x", buf[idx--]
            end
        end
        printf "]\n"
    end
end

def bytes(ptr, cnt, lab)
    if enabled
        label(lab) if lab
        auto pb = <uint8*>ptr
        while cnt--
            printf "%02x", *pb++
        end
        printf "\n"
    end
end

def label(lab)
    printf "%s = ", lab
end

def words(ptr, cnt, lab)
    if enabled
        label(lab) if lab
        printf "["
        auto pw = <uint32*>ptr
        auto sep = ""
        while cnt--
            printf "%s%08x", sep, *pw++
            sep = ", "
        end
        printf "]\n"
    end
end
