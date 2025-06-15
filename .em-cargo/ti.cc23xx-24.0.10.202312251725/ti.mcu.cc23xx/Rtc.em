package ti.mcu.cc23xx

import InterruptT { name: "CPUIRQ0" } as Intr

module Rtc

    type Handler: function()

    function disable()
    function enable(thresh: uint32, handler: Handler)
    function getMsecs(): uint32
    function getRaw(oSubs: uint32*): uint32
    function toThresh(ticks: uint32): uint32
    function toTicks(secs256: uint32): uint32

private:

    const MSECS_SCALAR: uint16 = 1000 / 8
    const RES_BITS: uint8 = 20

    var curHandler: Handler

    function isr: Intr.Handler

end

def em$construct()
    Intr.setHandlerH(isr)
end

def em$startup()
    ^^HWREG(CKMD_BASE + CKMD_O_LFINCOVR)^^ = 0x80000000 + (1 << RES_BITS)
    ^^HWREG(RTC_BASE + RTC_O_CTL)^^ = ^RTC_CTL_RST
    ^^HWREG(EVTSVT_BASE + EVTSVT_O_CPUIRQ0SEL) = EVTSVT_CPUIRQ0SEL_PUBID_AON_RTC_COMB^^
    Intr.enable()
end

def disable()
    curHandler = null
    ^^HWREG(RTC_BASE + RTC_O_IMCLR)^^ = ^RTC_IMCLR_EV0
end

def enable(thresh, handler)
    curHandler = handler
    ^^HWREG(RTC_BASE + RTC_O_CH0CC8U)^^ = thresh
    ^^HWREG(RTC_BASE + RTC_O_IMSET)^^ = ^RTC_IMSET_EV0
end

def getMsecs()
    auto ticks = <uint32>^^HWREG(RTC_BASE + RTC_O_TIME8U)^^
    return (ticks * MSECS_SCALAR) >> (RES_BITS - 7)
end

def getRaw(oSubs)
    var lo: uint32
    var hi: uint32
    for ;;
        lo = ^^HWREG(RTC_BASE + RTC_O_TIME8U)^^
        hi = ^^HWREG(RTC_BASE + RTC_O_TIME524M)^^
        break if lo == ^^HWREG(RTC_BASE + RTC_O_TIME8U)^^
    end
    *oSubs = lo << 16
    return hi
end

def isr()
    ^^HWREG(RTC_BASE + RTC_O_ICLR)^^ = ^RTC_ICLR_EV0
    curHandler() if curHandler
end


def toThresh(ticks)
    return ^^HWREG(RTC_BASE + RTC_O_TIME8U)^^ + ticks
end

def toTicks(secs256)
    return secs256 << 8
end