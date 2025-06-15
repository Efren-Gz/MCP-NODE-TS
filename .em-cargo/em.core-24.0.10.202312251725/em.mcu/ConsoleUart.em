package em.mcu

from em.hal import ConsoleUartI
from em.hal import ConsoleUartN

module ConsoleUart: ConsoleUartI

    proxy Impl: ConsoleUartI

end

def em$configure()
    Impl ?= ConsoleUartN
end

def setBaudH(rate)
    Impl.setBaudH(rate)
end

def flush()
    Impl.flush()
end

def put(data)
    Impl.put(data)
end
