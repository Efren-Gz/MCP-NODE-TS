package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em.mcu import Common

module BlinkerDbgP

    config dbgFlag: bool = true

    config minCnt: uint16 = 1000
    config maxCnt: uint16 = 1020 

end

def em$run()
    AppLed.on()
    for cnt: uint16 = minCnt; cnt < maxCnt; cnt++
        %%[d+]
        Common.BusyWait.wait(500 * 1000L)
        %%[d-]
        AppLed.toggle()
        continue if !dbgFlag
        fail if cnt > ((minCnt + maxCnt) / 2)
        %%[>cnt]
        var bits11: uint8 = cnt & 0b0011
        %%[>bits11]
        %%[c:bits11]
        printf "cnt = %d (0x%04x), bits11 = %d\n", cnt, cnt, bits11
    end
    AppLed.off()
    halt
end
