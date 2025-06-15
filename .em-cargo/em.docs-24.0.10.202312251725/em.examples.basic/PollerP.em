package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed

from em.mcu import Common
from em.mcu import Poller

module PollerP

end

def em$run()
    Common.GlobalInterrupts.enable()
    auto k = 5
    while k--
        Poller.pause(100)   # 100ms
        AppLed.wink(5)      # 5ms
    end
end
