package em.utils

from em.hal import OneShotMilliI
from em.hal import TimeoutI

module TimeoutAux: TimeoutI

    proxy OneShot: OneShotMilliI

private:

    var flag: bool volatile

    function handler: OneShot.Handler

end

def active()
    return flag
end

def cancel()
    flag = false
    OneShot.disable()
end

def handler(arg)
    cancel()
end

def set(msecs)
    flag = true
    OneShot.enable(msecs, handler, null)
end
