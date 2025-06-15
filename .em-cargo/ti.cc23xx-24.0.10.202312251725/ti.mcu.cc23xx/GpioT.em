package ti.mcu.cc23xx

template GpioT

    const UNDEF: int16 = -1

    config pin: int16 = UNDEF

end

def em$generateUnit(pn, un)
    auto bq = "`"
    auto pre = ^^pn.replace(/[.]/g, '_') + '_' + un + '__'^^
|->>>
    package `pn`
    
    from em.hal import GpioI
    
    module `un`: GpioI
    
        config pin: int16 = `pin`

        function pinMask(): uint32    

    private:
    
        config isDef: bool
        config mask: uint32
    
    end
    
    def em$construct()
        isDef = pin != `UNDEF`
        mask = isDef ? <uint32>(1 << <uint8>pin) : 0
    end

    def clear() 
        ^^HWREG(GPIO_BASE + GPIO_O_DOUTCLR31_0)^^ = mask if isDef
    end
    
    def set()
        ^^HWREG(GPIO_BASE + GPIO_O_DOUTSET31_0)^^ = mask if isDef
    end
    
    def get()
        return 0 if !isDef
        return isInput() ? ((^^HWREG(GPIO_BASE + GPIO_O_DIN31_0)^^ & mask) != 0) : ((^^HWREG(GPIO_BASE + GPIO_O_DOUT31_0)^^ & mask) != 0)
    end
    
    def toggle()
        ^^HWREG(GPIO_BASE + GPIO_O_DOUTTGL31_0)^^ = mask if isDef
    end

    def isInput()
        return isDef && (^^HWREG(GPIO_BASE + GPIO_O_DOE31_0)^^ & mask) == 0
    end
    
    def isOutput()
        return isDef && (^^HWREG(GPIO_BASE + GPIO_O_DOE31_0)^^ & mask) != 0
    end
    
    def makeInput()
        ^^HWREG(GPIO_BASE + GPIO_O_DOECLR31_0)^^ = mask if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= ^IOC_IOC0_INPEN if isDef
    end

    def makeOutput()
        ^^HWREG(GPIO_BASE + GPIO_O_DOESET31_0)^^ = mask if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ &= ~^IOC_IOC0_INPEN if isDef
    end
     
    def functionSelect(select)
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ = select if isDef
    end
    
    def setInternalPullup(enable)
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= ^IOC_IOC0_PULLCTL_PULL_UP if isDef && enable
    end

    def pinId()
        return pin
    end
    
    def pinMask()
        return mask
    end

    def reset()
        ^^HWREG(GPIO_BASE + GPIO_O_DOECLR31_0)^^ = mask if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= (^IOC_IOC0_IOMODE_M | ^IOC_IOC0_PULLCTL_M) if isDef
    end
|-<<<
end
