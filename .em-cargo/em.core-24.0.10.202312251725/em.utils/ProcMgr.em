package em.utils

from em.mcu import Common
from em.utils import BasicListManager

module ProcMgr

    type ProcFxn: function(arg: uarg_t)

    type Proc: opaque
        host function declareStartH()
        host function initH(fxn: fxn_t, arg: uarg_t = 0)
        function arg(a: uarg_t)
        function fxn(f: fxn_t)
        function getArg(): uarg_t
        function getFxn(): fxn_t
        function post()
    end

    host function createH(fxn: fxn_t, arg: uarg_t = 0): Proc&
    
    function run()

private:

    def opaque Proc
        elem: BasicListManager.Element
        fxn_: fxn_t
        arg_: uarg_t
    end

    function dispatch()
    
    config startP: Proc&

    var procList: BasicListManager.List

end

def em$construct() 
    procList.initH()
end

def em$startup()
    startP.post() if startP && !Common.Mcu.isWarm()
end

def createH(fxn, arg)
    auto proc = new<Proc>
    proc.initH(fxn, arg)
    return proc
end

def dispatch()
    for ;;
        break if procList.hasElements() == 0
        auto proc = <Proc&>procList.get()
        Common.GlobalInterrupts.enable()
        auto fxn = <ProcFxn>proc.fxn_
        fxn(proc.arg_)
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

def Proc.declareStartH()
    startP = this
end

def Proc.initH(fxn, arg)
    this.elem.initH()
    this.fxn_ = fxn
    this.arg_ = arg
end

def Proc.arg(a)
    this.arg_ = a
end

def Proc.fxn(f)
    this.fxn_ = f
end

def Proc.getArg()
    return this.arg_
end

def Proc.getFxn()
    return this.fxn_
end

def Proc.post()
    auto key = Common.GlobalInterrupts.disable()
    procList.add(this.elem) if !this.elem.isActive()
    Common.GlobalInterrupts.restore(key)
end

