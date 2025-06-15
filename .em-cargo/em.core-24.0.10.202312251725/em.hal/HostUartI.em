package em.hal

import ConsoleUartI

interface HostUartI: ConsoleUartI

    type RxHandler: function(b: uint8)
    
    function disable()
    function enable()
    function get(): uint8

    host function setRxHandlerH(handler: RxHandler)

end
