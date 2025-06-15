package em.utils

import Logger

module Error

    type Kind: enum
        APPLICATION, ASSERTION, EXCEPTION, EXPIRATION, WATCHDOG
    end

    type RaiseFxn: function (kind: Kind, infoA: iarg_t, infoB: iarg_t)

    host function bindOnRaiseH(fxn: RaiseFxn)
    function raise: RaiseFxn

private:

    config KIND_ATOM: atom_t[] = [
        @"APPLICATION", @"ASSERTION", @"EXCEPTION", @"EXPIRATION", @"WATCHDOG"
    ]

    config errorE: Logger.EventKind&
    config onRaiseFxn: RaiseFxn

end

def em$construct()
    ## TODO -- atomize error kind
    errorE = Logger.declareEventH("ERROR: $a [0x%08x, 0x%08x]", "*--*")
end

def bindOnRaiseH(fxn)
    onRaiseFxn = fxn
end

def raise(kind, infoA, infoB)
    errorE.log(<addr_t>KIND_ATOM[<uint8>kind], <addr_t>infoA, <addr_t>infoB)
    onRaiseFxn(kind, infoA, infoB) if onRaiseFxn
end
