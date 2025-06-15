package ti.mcu.cc23xx

from em.hal import BusyWaitI

module BusyWaitSysTick: BusyWaitI

end

def wait(usecs)
    ^^SysTick->VAL^^ = 0
    ^^SysTick->LOAD^^ = usecs
    ^^SysTick->CTRL |= SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_ENABLE_Msk^^
    while ^^SysTick->CTRL & SysTick_CTRL_COUNTFLAG_Msk^^ != 0
        %%[d]
    end
    ^^SysTick->CTRL^^ = 0
end
