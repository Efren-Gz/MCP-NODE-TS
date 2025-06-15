package ti.mcu.cc23xx

from em.hal import McuI

from em.lang import Debug

module Mcu: McuI

    config noCache: bool
    config hasLfXtal: bool

end

def getResetCode()
    ## TODO -- implement
    return 0
end

def getStashAddr()
    ## TODO -- implement
    return null
end

def isWarm()
    ## TODO -- implement
    return false
end

def readEui48(dst)
    ## TODO -- implement
end

def reset(code)
    ## TODO -- implement
end

def startup()
    Debug.startup()
    if hasLfXtal
        ^^HWREG(CKMD_BASE + CKMD_O_LFINCOVR) = 0x001E8480 | CKMD_LFINCOVR_OVERRIDE_M^^
        ^^HWREG(CKMD_BASE + CKMD_O_LFCLKSEL) = CKMD_LFCLKSEL_MAIN_LFXT^^
        ^^HWREG(CKMD_BASE + CKMD_O_LFXTCTL) = CKMD_LFXTCTL_EN^^
        ^^HWREG(CKMD_BASE + CKMD_O_IMSET) = CKMD_IMASK_LFCLKGOOD^^
    else
        ^^HWREG(CKMD_BASE + CKMD_O_TRIM1) |= CKMD_TRIM1_NABIAS_LFOSC^^
        ^^HWREG(CKMD_BASE + CKMD_O_LFCLKSEL) = CKMD_LFCLKSEL_MAIN_LFOSC^^
        ^^HWREG(CKMD_BASE + CKMD_O_LFOSCCTL) = CKMD_LFOSCCTL_EN^^
        ^^HWREG(CKMD_BASE + CKMD_O_LFINCCTL) &= ~CKMD_LFINCCTL_PREVENTSTBY_M^^
        ^^HWREG(CKMD_BASE + CKMD_O_IMSET) = CKMD_IMASK_LFCLKGOOD^^
    end
    ^^HWREG(CLKCTL_BASE + CLKCTL_O_IDLECFG)^^ = 1 if noCache
    ^^HWREG(VIMS_BASE + VIMS_O_CCHCTRL)^^ = 0 if noCache
end

def shutdown()
    ## TODO -- implement
end
