package em.hal

interface UptimerI

    type Time: struct
        secs: uint32
        subs: uint32
        ticks: uint32
    end

    function calibrate(secs256: uint32, ticks: uint32): uint16
    function read(): Time&
    function resetSync()
    function trim(): uint16

end
