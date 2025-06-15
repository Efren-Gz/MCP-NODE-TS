package em.lang

import AssertProviderI
import AssertProviderN

module Assert

    proxy Provider: AssertProviderI

    function enabled(): bool
    function trigger(upath: atom_t, line: uint16, msg: atom_t = 0, arg1: iarg_t = 0, arg2: iarg_t = 0)

end

def em$configure()
    Provider ?= AssertProviderN
end

def enabled()
    return Provider.enabled()
end

def trigger(upath, line, msg, arg1, arg2)
    Provider.trigger(upath, line, msg, arg1, arg2) if enabled()
end
