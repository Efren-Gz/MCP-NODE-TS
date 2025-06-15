package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em.mcu import Common

module BlinkerP

end

def em$run()
    AppLed.on()
    for auto i = 0; i < 10; i++
        Common.BusyWait.wait(500 * 1000L)
        AppLed.toggle()
    end
    AppLed.off()
end
