package em.hal

interface PollerI
        #       ^| abstration of periodic polling
    type PollFxn: function(): bool
        #       ^| signature of a boolean-valued polling function
    function poll(rateMs: uint16, count: uint16, fxn: PollFxn): uint16 
        #       ^| initiates a polling sequence
        #       ^| @rateMs - idle time in milliseconds between pollings
        #       ^| @count - maximum number of polling attempts
        #       ^| @fxn - the polling function itself
        #       ^| @return - the number of polling attempts remaining (success if >0)
end
