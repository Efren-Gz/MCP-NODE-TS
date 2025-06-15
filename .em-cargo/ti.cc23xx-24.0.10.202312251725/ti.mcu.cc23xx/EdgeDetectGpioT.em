package ti.mcu.cc23xx

template EdgeDetectGpioT

    const UNDEF: int8 = -1

    config pin: int8 = UNDEF

end

def em$generateUnit(pn, un)
    auto bq = "`"
    auto p = pin
    auto pre = ^^pn.replace(/[.]/g, '_') + '_' + un + '__'^^
|->>>
    package `pn`
    
    from ti.mcu.cc23xx import EdgeDetectGpioAux as Aux
    from ti.mcu.cc23xx import GpioT {} as Pin

    from em.hal import GpioEdgeDetectMinI
     
    module `un`: GpioEdgeDetectMinI
    
        config pin: int16 = `p`

    private:
    
        config isDef: bool
        config mask: uint32        

        var info: Aux.HandlerInfo
    
    end
    
    def em$configure()
        Pin.pin ?= pin
    end

    def em$construct()
        isDef = pin != `UNDEF`
        mask = isDef ? <uint32>(1 << <uint8>pin) : 0
        info.mask = mask
    end
     
    def em$startup()
        Aux.addHandler(info)
    end    

    def clear() 
        Pin.clear()
    end
    
    def set()
        Pin.set()
    end
    
    def get()
        return Pin.get()
    end
    
    def toggle()
        Pin.toggle()
    end

    def isInput()
        return Pin.isInput()
    end
    
    def isOutput()
        return Pin.isOutput()
    end
    
    def makeInput()
        Pin.makeInput()
    end
    
    def makeOutput()
        Pin.makeOutput()
    end
     
    def functionSelect(select)
        Pin.functionSelect(select)
    end
    
    def setInternalPullup(enable)
        Pin.setInternalPullup(enable)
    end
    
    def pinId()
        return pin
    end

    def reset()
        Pin.reset()
    end

    def enableDetect()
        ^^HWREG(GPIO_BASE + GPIO_O_IMSET)^^ = mask if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= ^IOC_IOC0_WUENSB if isDef
    end
     
    def disableDetect()
        ^^HWREG(GPIO_BASE + GPIO_O_IMCLR)^^ = mask if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ &= ~^IOC_IOC0_WUENSB if isDef
    end
     
    def clearDetect()
        ^^HWREG(GPIO_BASE + GPIO_O_ICLR)^^ = mask if isDef
    end
     
    def setDetectRisingEdge()
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ &= ~^IOC_IOC0_EDGEDET_M if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= ^IOC_IOC0_EDGEDET_EDGE_POS if isDef
    end
     
    def setDetectFallingEdge()
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ &= ~^IOC_IOC0_EDGEDET_M if isDef
        ^^HWREG(IOC_BASE + IOC_O_IOC0 + pin * 4)^^ |= ^IOC_IOC0_EDGEDET_EDGE_NEG if isDef
    end
     
    def setDetectHandlerH(h)
        info.handler = <Aux.Handler>h
    end
|-<<<
end
