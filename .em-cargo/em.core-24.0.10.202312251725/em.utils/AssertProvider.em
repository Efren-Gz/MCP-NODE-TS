package em.utils

from em.lang import AssertProviderI

import Error
import Logger

module AssertProvider: AssertProviderI

private:

    config assertMsgE: Logger.EventKind&
    config assertSiteE: Logger.EventKind&

end

def em$construct()
    assertMsgE = Logger.declareEventH("ASSERT: $F", "*--*")
    assertSiteE = Logger.declareEventH("ASSERT: $a, line %d", "*--*")
end

def enabled()
    return Logger.POLICY != Logger.Policy.NIL
end

def trigger(upath, line, msg, arg1, arg2)
    assertSiteE.log(<addr_t>upath, line)
    assertMsgE.log(<addr_t>msg, <addr_t>arg1, <addr_t>arg2) if msg
    Error.raise(Error.Kind.ASSERTION, 0, 0)
end
