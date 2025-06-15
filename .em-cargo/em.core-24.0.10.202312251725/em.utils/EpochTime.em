package em.utils

from em.hal import UptimerI

module EpochTime

    proxy Uptimer: UptimerI

    type UpdateFxn: function(esecs: uint32, esubs: uint32)

    host function bindUpdateFxnH(fxn: UpdateFxn)

    function getCurrent(oSubs: uint32* = null): uint32
    function getRaw(oSubs: uint32* = null): uint32
    function mkSecs256(secs: uint32, subs: uint32): uint32
    function setCurrent(eSecs: uint32, eSubs: uint32 = 0, syncFlag: bool = false)

private:

    config updateFxn: UpdateFxn

    var deltaSecs: uint32
    var deltaSubs: uint32
    
    var lastSecs256: uint32
    var lastTicks: uint32

    function compute(time: Uptimer.Time&, oSubs: uint32*): uint32

end

def bindUpdateFxnH(fxn)
    updateFxn = fxn
end

def compute(time, oSubs)
    auto eSubs = time.subs + deltaSubs
    auto inc = eSubs < time.subs ? 1 : 0
    (*oSubs) = eSubs if oSubs
    return time.secs + deltaSecs + inc
end

def getCurrent(oSubs)
    return compute(Uptimer.read(), oSubs)
end

def getRaw(oSubs)
    auto time = Uptimer.read()
    *oSubs = time.subs if oSubs
    return time.secs
end

def mkSecs256(secs, subs)
    return (secs << 8) | (subs >> 24)
end

def setCurrent(eSecs, eSubs, syncFlag)
    auto time = Uptimer.read()
    deltaSubs = eSubs - time.subs
    auto dec = deltaSubs > eSubs ? 1 : 0
    deltaSecs = eSecs - time.secs - dec
    auto eSecs256 = mkSecs256(eSecs, eSubs)
    if syncFlag
        Uptimer.calibrate(eSecs256 - lastSecs256, time.ticks - lastTicks) if lastSecs256
        lastSecs256 = eSecs256
        lastTicks = time.ticks
    else
        lastSecs256 = lastTicks = 0
    end
    var subs: uint32
    auto secs = compute(time, &subs)
    updateFxn(eSecs, eSubs) if updateFxn
end
