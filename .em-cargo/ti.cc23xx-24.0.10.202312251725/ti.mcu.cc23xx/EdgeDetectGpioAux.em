package ti.mcu.cc23xx

import InterruptT { name: "GPIO_COMB" } as Intr

module EdgeDetectGpioAux

    type Handler: function ()

    type HandlerInfo: struct
        link: HandlerInfo&
        mask: uint32
        handler: Handler
    end

    function addHandler(hi: HandlerInfo&)
 
 private:

    var handlerList: HandlerInfo&
    function edgeIsr: Intr.Handler

end

def em$construct()
    Intr.setHandlerH(edgeIsr)
end

def em$startup()
    Intr.enable()
end

def addHandler(hi)
    hi.link = handlerList
    handlerList = hi
end

def edgeIsr()
    auto mis = <uint32>^^HWREG(GPIO_BASE + GPIO_O_MIS)^^
    for hi: HandlerInfo& = handlerList; hi != null; hi = hi.link
        hi.handler() if (mis & hi.mask) && hi.handler
    end
    ^^HWREG(GPIO_BASE + GPIO_O_ICLR)^^ = 0xffffffff
end
