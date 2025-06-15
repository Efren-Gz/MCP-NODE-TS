package em.lang

interface DebugPinI

    function clear()
    function get(): bool
    function set()
    function toggle()
    function pulse()
    function mark(k: uint8 = 0)
    function reset()
    function startup()

end
