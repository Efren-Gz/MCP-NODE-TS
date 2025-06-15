package ti.mcu.cc23xx

template InterruptT

    config name: string

end

def em$generateUnit(pn, un) 
    auto intrName = name
    auto handlerNameQ = "`" + un + ".handlerName`"
|->>>
    package `pn`
    
    from ti.mcu.cc23xx import IntrVec

    from em.hal import InterruptSourceI
    
    module `un`: InterruptSourceI 
    
    private:
        host var handlerName: string
    end
    
    def em$construct()
        IntrVec.addIntrH("`intrName`")
    end

    def em$generateCode( prefix )
        if `un`.handlerName
            |-> void `intrName`_Handler() {
            |->     `handlerNameQ`();
            |-> }
        end
    end
    
    def setHandlerH(h)
        handlerName = h ? ^^String(h).substring(1)^^ : null
    end
    
    def enable() 
        ^^NVIC_EnableIRQ(`intrName`_IRQn)^^
    end
    
    def disable() 
        ^^NVIC_DisableIRQ(`intrName`_IRQn)^^
    end
    
    def clear()
        ^^NVIC_ClearPendingIRQ(`intrName`_IRQn)^^
    end
    
    def isEnabled() 
        return ^^NVIC_GetEnableIRQ(`intrName`_IRQn)^^
    end
|-<<<
end
