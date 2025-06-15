package em.hal

interface TimeoutI

    function active(): bool
    function cancel()
    function set(msecs: uint32)

end
