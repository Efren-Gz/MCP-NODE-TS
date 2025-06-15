package em.utils

from em.hal import MsCounterI
from em.hal import UptimerI

module MsCounterUptimer: MsCounterI

    proxy Uptimer: UptimerI

private:

    var t0: uint32

    function readMsecs(): uint32

end

def readMsecs()
    auto time = Uptimer.read()
    return ((time.secs & 0xFF) << 16) + (time.subs >> 16)
end

def start()
    t0 = readMsecs()
end

def stop()
    return 0 if t0 == 0
    auto dt = readMsecs() - t0
    t0 = 0
    return (dt * 1000) >> 16
end
