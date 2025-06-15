 package em.hal

interface OneShotMilliI
        #   ^| abstraction of a one-shot timer with millisecond resolution
    type Handler: function(arg: ptr_t)
        #   ^| handler function signature
    function disable()
        #   ^| disables the timer
    function enable(msecs: uint32, handler: Handler, arg: ptr_t = null) 
        #   ^| enables the timer to expire in msecs milliseconds
        #   ^| @msecs - duration in millisecs before expiration
        #   ^| @handler - handler function called upon expiration 
        #   ^| @arg - optional value passed to the handler
end
