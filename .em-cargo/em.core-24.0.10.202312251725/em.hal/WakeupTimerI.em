package em.hal

interface WakeupTimerI
        #   ^| abstraction of a free-running wakeup-timer (RTC)
    type Handler: function()
        #   ^| handler function signature
    function disable()
        #   ^| disables any pending wakeup from the timer
    function enable(thresh: uint32, handler: Handler)
        #   ^| enables a future wakeup from the timer
        #   ^| @thresh - an internal timer threshold value
        #   ^| @handler - the function called when reaching the threshold
    function secs256ToTicks(secs256: uint32): uint32
        #   ^| converts secs256 to logical timer ticks
    function ticksToThresh(ticks: uint32): uint32
        #   ^| converts timer ticks to an internal timer threshold value
    function timeToTicks(secs: uint32, subs: uint32): uint32
        #   ^| converts secs+subs time value to logical timer ticks
        #   ^| @secs - the seconds component of the time value
        #   ^| @subs - the sub-seconds component of the time value
        #   ^| @return - time value represented as logic timer ticks
end
