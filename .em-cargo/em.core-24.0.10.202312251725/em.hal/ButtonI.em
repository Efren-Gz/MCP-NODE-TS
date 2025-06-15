package em.hal

interface ButtonI
        #   ^| abstraction of a pressable button
    type OnPressedCB: function()
        #   ^| signature of a button's callback function
    function isPressed(): bool
        #   ^| test whether this button is currently pressed
    function onPressed(cb: OnPressedCB, minDurationMs: uint16 = 100, maxDurationMs: uint16 = 4000)
        #   ^| bind a callback to this button
        #   ^| @cb - callback function, executed when this button is pressed
        #   ^| @minDurationMs - minimum time in millisecs before executing this button's callback
        #   ^| @maxDurationMs - maximum time in millisecs, after which this button's callback is executed

end
