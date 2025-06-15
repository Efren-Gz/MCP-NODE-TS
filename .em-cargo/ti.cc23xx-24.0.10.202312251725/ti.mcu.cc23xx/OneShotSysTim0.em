package ti.mcu.cc23xx

import InterruptT { name: "CPUIRQ1" } as Intr

import Idle
import Mcu

from em.hal import OneShotMilliI

module OneShotSysTim0: OneShotMilliI

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
    ^^HWREG(SYSTIM_BASE + SYSTIM_O_ICLR) = SYSTIM_ICLR_EV0^^
end

def enable(msecs, handler, arg)
    curFxn = handler
    curArg = arg
    Idle.setWaitOnly(true)
    Intr.clear()
    Intr.enable()
    ^^HWREG(EVTSVT_BASE + EVTSVT_O_CPUIRQ1SEL) = EVTSVT_CPUIRQ1SEL_PUBID_SYSTIM0^^
    ^^HWREG(SYSTIM_BASE + SYSTIM_O_IMSET) = SYSTIM_IMSET_EV0^^
    auto time1u = <uint32>(^^HWREG(SYSTIM_BASE + SYSTIM_O_TIME1U)^^)
    auto thresh = time1u + (msecs * 1000)
    ^^HWREG(SYSTIM_BASE + SYSTIM_O_CH0CC)^^ = thresh
    printf "time1u = %d, thresh = %d\n", time1u, thresh
end

def isr()
    %%[a]
    auto fxn = curFxn
    disable()
    fxn(curArg) if fxn
end
