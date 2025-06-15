package em.hal

import HostUartI

module HostUartN: HostUartI
    #   ^| Nil implementation of the HostUartI interface
end

def setBaudH(rate)
    ## TODO -- implement
end

def flush()
    ## TODO -- implement
end

def put(data)
    ## TODO -- implement
end

def disable()
    ## TODO -- implement
end

def enable()
    ## TODO -- implement
end

def get()
    ## TODO -- implement
    return 0
end

def setRxHandlerH(handler)
    ## TODO -- implement
end
