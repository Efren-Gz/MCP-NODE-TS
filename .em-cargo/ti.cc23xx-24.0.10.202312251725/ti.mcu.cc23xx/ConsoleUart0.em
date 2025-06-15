package ti.mcu.cc23xx

from em.hal import ConsoleUartI
from em.hal import GpioI

from em.lang import Math

import Idle
import Mcu

module ConsoleUart0: ConsoleUartI

    proxy TxPin: GpioI

private:

    config baud: uint32
    config fbrd: uint32
    config ibrd: uint32

    function sleepEnter: Idle.Callback
    function sleepLeave: Idle.Callback

end

def em$construct()
    Idle.addSleepEnterCbH(sleepEnter)
    Idle.addSleepLeaveCbH(sleepLeave)
    auto brd = <num_t>(Mcu.mclkFrequency / (baud * 16))
    ibrd = Math.floor(brd)
    fbrd = Math.round((brd - ibrd) * 64)
end

def em$startup()
    sleepLeave()
end

def setBaudH(rate)
    baud = rate
end

def sleepEnter()
    ^^HWREG(CLKCTL_BASE + CLKCTL_O_CLKENCLR0)^^ = ^CLKCTL_CLKENSET0_UART0
    TxPin.reset()
end

def sleepLeave()
    ^^HWREG(CLKCTL_BASE + CLKCTL_O_CLKENSET0)^^ = ^CLKCTL_CLKENSET0_UART0
    TxPin.makeOutput()
    TxPin.set()
    TxPin.functionSelect(2)
    ^^HWREG(UART0_BASE + UART_O_CTL)^^ &= ~^UART_CTL_UARTEN
    ^^HWREG(UART0_BASE + UART_O_IBRD)^^ = ibrd
    ^^HWREG(UART0_BASE + UART_O_FBRD)^^ = fbrd
    ^^HWREG(UART0_BASE + UART_O_LCRH)^^ = ^UART_LCRH_WLEN_BITL8
    ^^HWREG(UART0_BASE + UART_O_CTL)^^ |= ^UART_CTL_UARTEN
end

def flush()
    while (^^HWREG(UART0_BASE + UART_O_FR)^^ & ^UART_FR_BUSY) != 0
    end
end

def put(data)
    ^^HWREG(UART0_BASE + UART_O_DR)^^ = data
    flush()
end
