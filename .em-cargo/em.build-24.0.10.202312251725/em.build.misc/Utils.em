package em.build.misc

from em.lang import BuildC

host module Utils

    type SectDesc: struct
        addr: uint32
        size: uint32
        memory: string
        sectid: string
    end

    function addInclude(path: string)
    function addObjectFile(path: string)
    function addOption(opt: string)
    function addSection(addr: uint32, size: uint32, memory: string, sectid: string)
    function copy(dstdir: string, srcfile: string, srcpkg: string)
    function findCanonical(path: string): string
    template genDefines()
    function getSections(): SectDesc&[]
    function setOptimize(level: string)

private:

    function mkId(pval: string): string
    var sectTab: SectDesc&[]

end

def addInclude(path)
    var cincs: string = ^^em$props.get('em.build.CompileIncludes')^^
    cincs += ^^em$find(path) + ';'^^
    ^^em$props.set('em.build.CompileIncludes', cincs)^^
end

def addObjectFile(path)
    var lobjs: string = ^^em$props.get('em.build.LinkerObjects')^^
    lobjs += ^^em$find(path) + ';'^^
    ^^em$props.set('em.build.LinkerObjects', lobjs)^^
end

def addOption(opt)
    var copts: string = ^^em$props.get('em.build.CompileOptions')^^
    copts += " " + opt
    ^^em$props.set('em.build.CompileOptions', copts)^^
end

def addSection(addr, size, memory, sectid)
    auto sect = new <SectDesc>
    sect.addr = addr
    sect.size = size
    sect.memory = memory
    sect.sectid = sectid
    sectTab[sectTab.length++] = sect
end

def copy(dstdir, srcfile, srcpkg)
    ^^let srcpath = em$find(`${srcpkg}/${srcfile}`)^^
    return if ^^!srcpath^^
    ^^let dstpath = `${dstdir}/${srcfile}`^^
    ^^$Fs.writeFileSync(dstpath, $Fs.readFileSync(srcpath))^^
end

def findCanonical(path)
    return ^^em$find(path).replace(/\\/g, '/')^^
end

def genDefines()
    auto isWarmSrc = "<" + ^^em$props.get('em.lang.Builder').split('/')[0]^^ + "/is_warm.c>"
        |->    -D__EM_ARCH_`BuildC.arch`__ \\
        |->    -D__EM_BOOT__=`BuildC.bootLoader ? 1 : 0` \\
        |->    -D__EM_BOOT_FLASH__=`BuildC.bootFlash ? 1 : 0` \\
        |->    -D__EM_COMPILER_`BuildC.compiler`__ \\
        |->    -D__EM_CPU_`mkId(BuildC.cpu)`__ \\
        |->    -D__EM_MCU_`BuildC.mcu`__ \\
        |->    -D__EM_IS_WARM_SRC=`isWarmSrc` \\
        |->    -D__EM_LANG__=1 \\
end

def getSections()
    return sectTab
end

def mkId(pval)
    return pval if !pval
    return ^^pval.replace(/-/g, '_').replace(/\+/g, 'plus')^^
end

def setOptimize(level)
    var copts: string = ^^em$props.get('em.build.CompileOptions')^^
    return if ^^copts.match(/ -O/)^^ || !level
    copts += " -O" + level
    ^^em$props.set('em.build.CompileOptions', copts)^^
end
