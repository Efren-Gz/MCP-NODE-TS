package em.utils

import BoardInfo

template BoardDriversGenT

    config driversPkg: string

end

def em$generateUnit(pn, un)
    auto brdRec = BoardInfo.readRecordH()
    auto drvPkg = driversPkg
            |->package `pn`
            |-> 
    for dd in brdRec.drvDescs
            |->from `drvPkg` import `dd.driver` as `dd.name`
    end
            |->
            |->module `un`
            |-> 
            |->end
end
