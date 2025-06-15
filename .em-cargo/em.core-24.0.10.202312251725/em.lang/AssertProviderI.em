package em.lang

interface AssertProviderI

    function enabled(): bool
    function trigger(upath: atom_t, line: uint16, msg: atom_t, arg1: iarg_t, arg2: iarg_t)

end
