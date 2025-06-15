package em.hal

#! Implemented by an Mcu module

interface McuI 

    const ADMIN_RESET: int8 = -1
    const HOST_RESET:  int8 = -2
    const COLD_RESET:  int8 = -3
    const FIRST_RESET: int8 = -4
    
    config mclkFrequency: uint32

    function getResetCode(): int8
    function getStashAddr(): ptr_t
    function isWarm(): bool
    function readEui48(dst: uint8*)

    #! Perform startup and shutdown operations specific for a particular Mcu
    function reset(code: int8 = 0)
    function startup()
    function shutdown()
end
