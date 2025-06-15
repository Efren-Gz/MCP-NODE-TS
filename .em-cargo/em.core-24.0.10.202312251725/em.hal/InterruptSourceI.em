package em.hal

#! Generally implemented by an Interrupt Template used to "create" interrupts

interface InterruptSourceI 

    type Handler: function()
    
    #! Sets the handler function for a particular interrupt
    host function setHandlerH(h: Handler)
    
    #! Enables a particular interrupt
    function enable()
    
    #! Disables a particular interrupt
    function disable()
    
    #! Clears the interrupt flag   
    function clear()
    
    #! True if the interrupt is enabled
    function isEnabled(): bool
end