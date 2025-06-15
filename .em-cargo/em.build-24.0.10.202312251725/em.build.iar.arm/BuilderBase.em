package em.build.iar.arm

from em.lang import BuilderI
from em.lang import BuildC

from em.build.misc import ShellRunner
from em.build.misc import Utils

host module BuilderBase: BuilderI

    config dmemBase: addr_t
    config dmemSize: uint32
    config imemBase: addr_t
    config imemSize: uint32
    config lmemBase: addr_t
    config lmemSize: uint32
    config vectSize: uint32

    config version: string

    template genScript(sysFlag: bool)

private:

    template genLink(bflg: bool)

    config typeInfo: TypeInfo = {
        ARG:    [4, 4],
        CHAR:   [1, 1],
        INT:    [4, 4],
        INT8:   [1, 1],
        INT16:  [2, 2],
        INT32:  [4, 4],
        LONG:   [4, 4],
        PTR:    [4, 4],
        SHORT:  [4, 4],
        SIZE:   [4, 4],
    }

end

def em$configure()
    BuildC.compiler ?= "iar"
end

def compile(buildDir)
    auto job = ShellRunner.exec(buildDir, "./build.sh")
    auto info = new <CompileInfo>
    info.procStat = job.status
    if info.procStat == 0
        auto re = "\\d:"
        var lines: string[] = ^^job.outlines.$elems.filter(ln => ln.match(new RegExp(re)))^^
        info.imageSizes = "image size: "
        auto textSz = 0
        auto constSz = 0
        auto dataSz = 0
        auto bssSz = 0
        for ln in lines
            ^^let words = ln.split(/\s+/)^^
            switch ^^words[1]^^
            case ".text"
                textSz = ^^Number(words[5])^^
            case ".const"
                constSz = ^^Number(words[5])^^
            case ".data"
                dataSz = ^^Number(words[5])^^
            case ".bss"
                bssSz = ^^Number(words[5])^^
            end
        end
        info.imageSizes = ^^`image size: text (${textSz}) + const (${constSz}) + data (${dataSz}) + bss (${bssSz})`^^
    else
        info.errMsgs = ^^['---- stderr ----\n', ...job.errlines.$elems, '---- stdout ----\n', ...job.outlines.$elems]^^
    end
    return info
end

def genLink(bflg)
    auto arch = BuildC.arch
    auto lflg = BuildC.bootFlash
    auto dmemOrg = <string>^^$sprintf("0x%08x", dmemBase)^^
    auto dmemLen = <string>^^$sprintf("0x%08x", dmemSize)^^
    auto imemOrg = <string>^^$sprintf("0x%08x", imemBase)^^
    auto imemLen = <string>^^$sprintf("0x%08x", imemSize)^^
                |-> define memory mem with size = 4G;
                |->
                |-> define region DMEM = mem:[from `dmemOrg` size `dmemLen`];
                |-> define region IMEM = mem:[from `imemOrg` size `imemLen`];
    for sd in Utils.getSections()
        auto mem = sd.memory
        auto org = <string>^^$sprintf("0x%08x", sd.addr)^^
        auto len = <string>^^$sprintf("0x%08x", sd.size)^^
                |-> define region `mem` = mem:[from `org` size `len`];
    end
                |-> 
                |-> initialize manually { section .data };
                |-> do not initialize { section .bss };
                |-> 
                |-> ".text": place at address `imemOrg` { section .intvec, section .start, section .text* };
                |-> keep { section .intvec, section .start };
                |-> 
                |-> ".const": place in IMEM { section .rodata* };
                |-> 
                |-> ".init": place in IMEM { section .data_init };
                |-> 
                |-> ".data": place in DMEM { section .data };
                |-> 
                |-> ".bss": place in DMEM { section .bss };
                |-> 
    for sd in Utils.getSections()
                |-> "`sd.sectid`": place in `sd.memory` { section `sd.sectid` };
                |-> keep { section `sd.sectid` };
                |-> 
    end
                |-> define symbol __stack_top__ = `dmemOrg` + `dmemLen`;
                |-> export symbol __stack_top__;
                
end

def genScript(sysFlag)
    Utils.setOptimize(BuildC.optimize)
    var cincs: string[] = ^^em$props.get('em.build.CompileIncludes').split(';').concat(em$paths)^^
    var copts: string[] = ^^em$props.get('em.build.CompileOptions').split(';')^^
    var cpu: string = BuildC.cpu
    var lobjs: string[] = ^^em$props.get('em.build.LinkerObjects').split(';')^^
    var tdir: string = ^^em$session.getToolsHome()^^ + "/ewarm_" + version + "/arm"
                |->TOOLS=`tdir`
                |->DIR=.
                |->                 
                |->CC=$TOOLS/bin/iccarm
                |->LNK=$TOOLS/bin/ilinkarm
                |->ELF=$TOOLS/bin/ielftool
                |->DUMP=$TOOLS/bin/ielfdumparm
                |-> 
                |->CFLAGS="\\
                |->`Utils.genDefines()`
                |->     --aeabi \\
                |->     --cpu `cpu` \\
                |->     --dlib_config $TOOLS/inc/c/DLib_Config_Normal.h \\
                |->     -e \\
                |->     -I$DIR \\
                |->     --endian=little \\
                |->     --no_size_constraints \\
                |->     --no_wrap_diagnostics \\
                |->     --silent \\
                |->     --thumb \\
                |->"
                |->CINCS="\\
    for p in cincs
        p = ^^p.trim()^^
        continue if !p
                |->    -I`p` \\
    end
                |->    -I$TOOLS/inc
                |->"
                |->COPTS="\\
    for o in copts
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
                |->LFLAGS="\\
                |->     --cpu `cpu` \\
                |->     --diag_suppress=Ls014,Ls016,Ls017,Lt009 \\
                |->     --entry __em_program_start \\
                |->     --entry_list_in_address_order \\
                |->     --inline \\
                |->     --keep __vector_table \\
                |->     --no_vfe \\
                |->     --no_wrap_diagnostics \\
                |->     --silent \\
                |->     --use_optimized_variants=small \\
                |->     --warnings_are_errors \\
                |->"
                |->LOBJS="\\
    for o in lobjs
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
                |-> 
                |->$CC $CINCS $CFLAGS $COPTS --c++ $DIR/main.cpp -o $DIR/main.obj -lD $DIR/main.lst
                |->$LNK $LFLAGS --config linkcmd.ld --map $DIR/main.map -o $DIR/main.out $DIR/main.obj $LOBJS
                |->$ELF --silent --ihex $DIR/main.out $DIR/main.out.hex
                |->$DUMP --all -o $DIR/main.out.dis $DIR/main.out
                |->grep '  SECTIONS:' -A 20 $DIR/main.out.dis
                |->sha256sum main.out.hex | cut -c -8 >main.out.sha32

end

def getTypeInfo()
    return typeInfo
end

def populate(buildDir, sysFlag)
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd.ld`^^, genLink(BuildC.bootLoader))
    ^^$Fs.writeFileSync^^(^^`${buildDir}/build.sh`^^, genScript(sysFlag))
end
