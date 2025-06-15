package em.utils

from em.mcu import Common

import BoardController
import EpochTime

module AppControl

    function restart(status: int8)

private:

    type Stash: struct
        secs: uint32
        subs: uint32
    end
    
    function getStash(): Stash&
    function doReset(code: int8)

end

def em$startup()
    return if Common.Mcu.isWarm() || Common.Mcu.getResetCode() < 0
    auto stash = getStash()
    EpochTime.setCurrent(stash.secs, stash.subs, false)
end

def em$fail()
    BoardController.em$fail()
end

def em$halt()
    BoardController.em$halt()
end

def doReset(code)
    auto stash = getStash()
    stash.secs = EpochTime.getCurrent(&stash.subs)
    Common.Mcu.reset(code) 
end

def getStash()
    return Common.Mcu.getStashAddr()
end

def restart(status)
    doReset(status)
end
