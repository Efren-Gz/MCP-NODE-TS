package em.hal

interface BusyWaitI
        #   ^| abstraction of a spin-loop
    function wait(usecs: uint32)
        #   ^| enter a spin-loop
        #   ^| @usecs - duration in microseconds
end
