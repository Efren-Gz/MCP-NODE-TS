package em.hal

interface WatchdogI

    type Handler: function()

    function didBite(): bool
    function disable()
    function enable(secs: uint16, handler: Handler)
    function pet()

end
