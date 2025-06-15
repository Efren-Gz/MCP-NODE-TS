package em.hal

interface GpioI
        #   ^| abstraction of a GPIO pin
    function clear()
        #   ^| clear the value of this GPIO (low)
    function functionSelect (select: uint8)
        #   ^| select an alternative function of this GPIO
    function get(): bool
        #   ^| get the value of this GPIO
    function isInput(): bool
        #   ^| test if this GPIO is an input pin
    function isOutput(): bool
        #   ^| test if this GPIO is an output pin
    function makeInput()
        #   ^| make this GPIO an input pin
    function makeOutput()
        #   ^| make this GPIO an output pin
    function pinId(): int16
        #   ^| Return the pin ID of this GPIO
    function reset()
        #   ^| Reset this GPIO
    function set()
        #   ^| set the value of this GPIO (high)
    function setInternalPullup (state: bool)
        #   ^| enable/disable the internalpullup for this GPIO
    function toggle()
        #   ^| toggle the value of this GPIO
    
end
