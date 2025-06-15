package ti.mcu.cc23xx

from em.hal import BusyWaitI

module BusyWait: BusyWaitI

end

def wait(usecs)
    ^HapiWaitUs(usecs)
end
