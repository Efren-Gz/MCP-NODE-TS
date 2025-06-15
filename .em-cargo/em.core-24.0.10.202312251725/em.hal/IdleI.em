package em.hal

#! Should be implemented by an Idle module

interface IdleI  

    #! This function defines how the system idles
    function exec()

    #! This function is called during "warm" wakeups
    function wakeup()
end