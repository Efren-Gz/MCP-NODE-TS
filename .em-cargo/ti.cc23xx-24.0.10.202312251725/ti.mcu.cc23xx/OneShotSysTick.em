package ti.mcu.cc23xx

import InterruptT { name: "SysTick" } as Intr

import Idle
import Mcu

from em.hal import OneShotMilliI

module OneShotSysTick: OneShotMilliI

private:

    var curArg: ptr_t
    var curFxn: Handler

    function isr: Intr.Handler

end

def em$construct()
    Intr.setHandlerH(isr)
end

def em$startup()
    ^^SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk^^
end

def disable()
    curFxn = null
    Idle.setWaitOnly(false)
    Intr.disable()
    ^^SysTick->CTRL &= ~(SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk)^^
end

def enable(msecs, handler, arg)
    curFxn = handler
    curArg = arg
    Idle.setWaitOnly(true)
    Intr.enable()
    ^^SysTick->LOAD^^ = msecs * (Mcu.mclkFrequency / 1000)
    ^^SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk | SysTick_CTRL_TICKINT_Msk^^
end

def isr()
    auto fxn = curFxn
    disable()
    fxn(curArg) if fxn
end
