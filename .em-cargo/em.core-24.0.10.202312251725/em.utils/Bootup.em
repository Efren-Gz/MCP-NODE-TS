package em.utils

module Bootup

    type Fxn: function()

    host function addFxnH(fxn: Fxn)

    function exec()

private:

    config FXNTAB: Fxn volatile[]
    config fxnCnt: uint8

end

def em$construct()
    FXNTAB@bootMemory = true
end

def addFxnH(fxn)
    FXNTAB[fxnCnt++] = fxn
end

def exec()
    for auto i = 0; i < fxnCnt; i++
        FXNTAB[i]()
    end
end
