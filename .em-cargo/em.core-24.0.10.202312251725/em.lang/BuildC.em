package em.lang

composite BuildC

    config arch: string
    config bootFlash: bool
    config bootLoader: bool
    config compiler: string
    config cpu: string
    config jlinkDev: string
    config mcu: string
    config optimize: string

private:

    var curPval: string

    function getProp(pname: string): string

end

def em$preconfigure()
    arch ?= curPval if getProp("em.build.Arch")
    bootFlash ?= true if getProp("em.build.BootFlash")
    bootLoader ?= true if getProp("em.lang.BootLoader")
    compiler ?= curPval if getProp("em.build.Compiler")
    cpu ?= curPval if getProp("em.build.Cpu")
    jlinkDev ?= curPval if getProp("em.build.JlinkDev")
    mcu ?= curPval if getProp("em.build.Mcu")
    optimize ?= curPval if getProp("em.build.Optimize")
end

def getProp(pname)
    return curPval = ^^em$props.get^^(pname, null)
end
