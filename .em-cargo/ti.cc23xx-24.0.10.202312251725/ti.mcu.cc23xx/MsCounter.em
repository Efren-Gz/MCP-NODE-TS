package ti.mcu.cc23xx

from em.hal import MsCounterI

import Rtc

module MsCounter: MsCounterI

private:

    var t0: uint32

end

def start()
    t0 = Rtc.getMsecs()
end

def stop()
    return 0 if t0 == 0
    auto t1 = Rtc.getMsecs()
    auto dt = (t1 > t0) ? (t1 - t0) : (t0 - t1)
    t0 = 0
    return dt
end
