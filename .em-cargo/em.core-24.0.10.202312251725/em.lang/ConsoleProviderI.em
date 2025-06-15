package em.lang

interface ConsoleProviderI

    function flush()
    function print(fmt: string, a1: iarg_t = 0, a2: iarg_t = 0, a3: iarg_t = 0, a4: iarg_t = 0, a5: iarg_t = 0, a6: iarg_t = 0)
    function put(data: uint8)

end
