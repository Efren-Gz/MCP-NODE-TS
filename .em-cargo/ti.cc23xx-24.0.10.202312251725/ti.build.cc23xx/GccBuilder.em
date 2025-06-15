package ti.build.cc23xx

from em.build.misc import UniFlash
from em.build.misc import Utils

from em.build.gcc2 import BuilderBase as Base

from em.lang import BuilderI
from em.lang import BuildC

module GccBuilder: BuilderI

end

def em$configure()
    Base.gccFlav ?= "arm-none-eabi"
    if BuildC.bootFlash
        Base.dmemBase ?= 0x20005000
        Base.dmemSize ?= 0x4000
        Base.imemBase ?= 0x20000000
        Base.imemSize ?= 0x5000
        Base.lmemBase ?= 0x00000000
        Base.lmemSize ?= 0x80000
    else
        Base.dmemBase ?= 0x20000000
        Base.dmemSize ?= 0x9000
        Base.imemBase ?= 0x00000000
        Base.imemSize ?= 0x80000
    end
    Base.vectSize ?= 0x90
    Utils.addInclude("com.ti/devices/cc23x0r5")
    Utils.addSection(0x4e020000, 0x800, "FLASH_CCFG", ".ccfg")
end

def compile(buildDir)
    return <CompileInfo&>Base.compile(buildDir)
end

def getTypeInfo()
    return <TypeInfo&>Base.getTypeInfo()
end

def populate(buildDir, sysFlag)
    Base.populate(buildDir, sysFlag)
    Utils.copy(buildDir, "CC2340R5.ccxml", "ti.build.cc23xx")
    UniFlash.genLoadScript(buildDir, "CC2340R5")
end
