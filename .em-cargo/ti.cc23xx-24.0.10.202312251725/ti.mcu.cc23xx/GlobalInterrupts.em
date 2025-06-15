package ti.mcu.cc23xx

from em.hal import GlobalInterruptsI

module GlobalInterrupts: GlobalInterruptsI

end

def disable()
    auto key = <uarg_t>(^^__get_PRIMASK()^^)
    ^^__set_PRIMASK(1)^^
    return key
end

def enable()
    ^^__set_PRIMASK(0)^^
end

def restore(key)
    ^^__set_PRIMASK(key)^^
end
