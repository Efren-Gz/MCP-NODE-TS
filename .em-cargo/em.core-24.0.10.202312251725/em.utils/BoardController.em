package em.utils

from em.hal import ConsoleUartI
from em.hal import LedI

from em.mcu import Common
from em.mcu import ConsoleUart

import ConsoleProtocol

module BoardController

    proxy Led: LedI
    proxy Uart: ConsoleUartI

    config blinkRate: uint32 = 50000

private:    

    function blink(times: uint8, usecs: uint32)
    
end

def em$configure()
    Uart ?= ConsoleUart
end

def em$reset()
    Common.Mcu.startup() 
end

def em$startupDone()
    return if Common.Mcu.isWarm()
    Led.off()
    blink(2, blinkRate)
    Uart.flush()
    Uart.put(0)
    Uart.put(0)
    for auto i = 0; i < ConsoleProtocol.SOT_COUNT; i++
        Uart.put(ConsoleProtocol.SOT_BYTE)
    end
    Uart.flush()
end

def em$halt()
    Uart.put(ConsoleProtocol.EOT_BYTE)
    Common.GlobalInterrupts.disable()
    Led.on()
    Common.Mcu.shutdown()
end

def em$fail()
    Common.Mcu.shutdown()
    Common.GlobalInterrupts.disable()
    while true
        blink(2, blinkRate)
        for auto i = 0; i < 800; i++
            Common.BusyWait.wait(100)
        end
    end
end

def blink(times, usecs)
    auto k = (times * 2)
    while --k
        Led.toggle()
        Common.BusyWait.wait(usecs)    
    end
    Led.toggle()
end
