package em.hal

#! Interface implemented by a GlobalInterrupts module for a device.

interface GlobalInterruptsI 

    type Key: uarg_t
    
    #! Disables interrupts and saves state
    function disable(): Key
    
    #! Enables interrupts
    function enable()
    
    #! Restores interrupts to previous state
    function restore(key: Key)
end
