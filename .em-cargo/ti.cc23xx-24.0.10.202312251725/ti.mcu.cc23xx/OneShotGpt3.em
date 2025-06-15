package ti.mcu.cc23xx

import InterruptT { name: "LGPT3_COMB" } as Intr

import BusyWait
import Idle
import Mcu

from em.hal import OneShotMilliI

module OneShotGpt3: OneShotMilliI

private:

    var curArg: ptr_t
    var curFxn: Handler

    function isr: Intr.Handler

end

def em$construct()
    Intr.setHandlerH(isr)
end

def disable()
    curFxn = null
    Idle.setWaitOnly(false)
    Intr.disable()
    ^^HWREG(LGPT3_BASE + LGPT_O_ICLR) = LGPT_ICLR_TGT^^
end

def enable(msecs, handler, arg)
    curFxn = handler
    curArg = arg
    Idle.setWaitOnly(true)
    Intr.enable()
    ^^HWREG(CLKCTL_BASE + CLKCTL_O_CLKENSET0)^^ = ^CLKCTL_CLKENSET0_LGPT3
    ^^HWREG(LGPT3_BASE + LGPT_O_IMSET) = LGPT_IMSET_TGT^^
    ^^HWREG(LGPT3_BASE + LGPT_O_TGT)^^ = msecs * (Mcu.mclkFrequency / 1000)
    ^^HWREG(LGPT3_BASE + LGPT_O_CTL) = LGPT_CTL_MODE_UP_ONCE | LGPT_CTL_C0RST^^
end

def isr()
    auto fxn = curFxn
    disable()
    fxn(curArg) if fxn
end
