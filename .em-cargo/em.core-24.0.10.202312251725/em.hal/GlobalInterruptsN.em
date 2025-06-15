package em.hal

import GlobalInterruptsI

module GlobalInterruptsN: GlobalInterruptsI
    #   ^| Nil implementation of the GlobalInterruptsI interface
end

def disable()
    return 0
end

def enable()
end

def restore(key)
end
