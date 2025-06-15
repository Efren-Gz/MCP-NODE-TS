package em.utils

from em.lang import ConsoleProviderI

from em.mcu import ConsoleUart

import Formatter

module MinConsole: ConsoleProviderI

end

def flush()
    ConsoleUart.flush()
end

def print(fmt, a1, a2, a3, a4, a5, a6)
end

def put(data)
    ConsoleUart.put(data)
end
