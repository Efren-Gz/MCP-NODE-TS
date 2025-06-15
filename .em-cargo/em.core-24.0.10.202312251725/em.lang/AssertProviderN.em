package em.lang

import AssertProviderI

module AssertProviderN: AssertProviderI

end

def enabled()
    return false
end

def trigger(upath, line, msg, arg1, arg2)
end
