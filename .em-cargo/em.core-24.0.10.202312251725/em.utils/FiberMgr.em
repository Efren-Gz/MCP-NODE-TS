package em.utils

from em.mcu import Common
from em.utils import ListMgr

module FiberMgr
            #   ^| manages opaque fiber objects
    type FiberBodyFxn: function(arg: uarg_t)
            #   ^| function signature of fiber body
    type Fiber: opaque
            #   ^| opaque fiber object - public specification
        host function initH(fxn: FiberBodyFxn, arg: uarg_t = 0)
            #   ^| initialize this fiber and bind its function and argument
        function getArg(): uarg_t
            #   ^| get this fiber's body function argument
        function getFxn(): FiberBodyFxn
            #   ^| get this fiber's body function
        function post()
            #   ^| make this fiber ready-to-run
        function setArg(a: uarg_t)
            #   ^| set this fiber's body function argument
        function setFxn(f: FiberBodyFxn)
            #   ^| set this fiber's body function
    end

    host function createH(fxn: FiberBodyFxn, arg: uarg_t = 0): Fiber&
            #   ^| allocate and initialize a fiber; see Fiber.initH
    function run()
            #   ^| initiate dispatch of ready-to-run fibers
private:

    def opaque Fiber
        elem: ListMgr.Element
        fxn_: FiberBodyFxn
        arg_: uarg_t
    end

    function dispatch()

    var fiberTab: Fiber[]
    var readyList: ListMgr.List

end

def em$construct() 
    readyList.initH()
end

def createH(fxn, arg)
    var fiber: Fiber& = fiberTab[fiberTab.length++]
    fiber.initH(fxn, arg)
    return fiber
end

def dispatch()
    for ;;
        break if readyList.hasElements() == 0
        auto fiber = <Fiber&>readyList.get()
        Common.GlobalInterrupts.enable()
        auto fxn = fiber.fxn_
        fxn(fiber.arg_)
        Common.GlobalInterrupts.disable()
    end   
end

def run()
    Common.Idle.wakeup()
    Common.GlobalInterrupts.enable()
    for ;;
        Common.GlobalInterrupts.disable()
        dispatch()
        Common.Idle.exec()
    end
end

def Fiber.initH(fxn, arg)
    this.elem.initH()
    this.fxn_ = fxn
    this.arg_ = arg
end

def Fiber.post()
    auto key = Common.GlobalInterrupts.disable()
    readyList.add(this.elem) if !this.elem.isActive()
    Common.GlobalInterrupts.restore(key)
end

def Fiber.getArg()
    return this.arg_
end

def Fiber.setArg(a)
    this.arg_ = a
end

def Fiber.setFxn(f)
    this.fxn_ = f
end

def Fiber.getFxn()
    return this.fxn_
end
