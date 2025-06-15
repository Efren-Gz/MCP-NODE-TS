package em.utils

from em.hal import LedI

interface LedBlinkerI: LedI

    function blink(count: uint16, rateSecs: uint16 = 1, rateMs: uint16 = 0)

end
