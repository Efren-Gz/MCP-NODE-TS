package em.hal

interface LedI
        #   ^| abstraction of an LED
    function isOn(): bool
        #   ^| test if the LED is on
    function off()
        #   ^| turn the LED off
    function on()
        #   ^| turn the LED on
    function toggle()
        #   ^| toggle the LED
    function wink(msecs: uint16)
        #   ^| turn the LED on/off
        #   ^| @msecs duration in milliseconds
    end
