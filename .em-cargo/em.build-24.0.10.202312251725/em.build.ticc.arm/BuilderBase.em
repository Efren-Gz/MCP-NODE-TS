package em.build.ticc.arm

from em.lang import BuilderI
from em.lang import BuildC

from em.build.misc import BuilderBaseI
from em.build.misc import ShellRunner
from em.build.misc import Utils

host module BuilderBase: BuilderI

    config installDir: string
    
    config dmemBase: addr_t
    config ramPage: uint32
    config dmemSize: uint32
    config imemBase: addr_t
    config imemSize: uint32
    config lmemBase: addr_t
    config lmemSize: uint32
    config vectSize: uint32

    template genScript(sysFlag: bool)

private:

    const DESC_SIZE: uint8 = 16

    template genComp(name: string)
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
    BuildC.compiler ?= "ticc"
end

def compile(buildDir)
    auto job = ShellRunner.exec(buildDir, "./build.sh")
    auto info = new <CompileInfo>
    info.procStat = job.status
    if info.procStat == 0
        auto re = "^\\d"
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
                textSz = ^^Number('0x' + words[2])^^
            case ".const"
                constSz = ^^Number('0x' + words[2])^^
            case ".data"
                dataSz = ^^Number('0x' + words[2])^^
            case ".bss"
                bssSz = ^^Number('0x' + words[2])^^
            end
        end
        info.imageSizes = ^^`image size: text (${textSz}) + const (${constSz}) + data (${dataSz}) + bss (${bssSz})`^^
    else
        info.errMsgs = ^^['---- stderr ----\n', ...job.errlines.$elems, '---- stdout ----\n', ...job.outlines.$elems]^^
    end
    return info
end

def genComp(name)
    auto suf = (name == "main") ? "" : ("_" + name)
                |->echo building `name`.out ...
                |->$CC -c $CFLAGS $CINCS $COPTS --save-temps -o $DIR/`name`.obj $DIR/`name`.cpp
                |->$CC $DIR/main.obj $LOBJS -o $DIR/main.out -Wl,--map_file=main.map -Wl,linkcmd.ld $LFLAGS
                |->$HEX --intel `name`.out -o `name`.out.hex
                |->sha256sum `name`.out.hex | cut -c -8 >`name`.out.sha32
                |->$OBJDUMP -h -d `name`.out >`name`.out.dis
                |->$OBJDUMP -h `name`.out
end

def genLink(bflg)
    #
    #
    auto arch = BuildC.arch
    auto lflg = BuildC.bootFlash
    for sd in Utils.getSections()
                |->--retain`sd.sectid`
    end
                |->--retain .intvec
    if lflg
                |->--retain .start
                |->--retain .start_vec
    end
    auto dmemOrg = <string>^^$sprintf("0x%08x", dmemBase)^^
    auto dmemLen = <string>^^$sprintf("0x%08x", dmemSize)^^
    auto imemOrg = <string>^^$sprintf("0x%08x", imemBase)^^
    auto imemLen = <string>^^$sprintf("0x%08x", imemSize)^^
    auto lmemOrg = lflg ? <string>^^$sprintf("0x%08x", lmemBase)^^ : ""
    auto lmemLen = lflg ? <string>^^$sprintf("0x%08x", lmemSize)^^ : ""
                |->
                |->MEMORY {
                |->    DMEM : ORIGIN = `dmemOrg`, LENGTH = `dmemLen`
                |->    IMEM : ORIGIN = `imemOrg`, LENGTH = `imemLen`
    if lflg
                |->    LMEM : ORIGIN = `lmemOrg`, LENGTH = `lmemLen`
    end
    for sect in Utils.getSections()
        auto m = sect.memory
        auto a = <string>^^$sprintf("0x%08x", sect.addr)^^
        auto s = <string>^^$sprintf("0x%08x", sect.size)^^
                |->    `m` : ORIGIN = `a`, LENGTH = `s`
    end
                |->}
                |->
    auto codeLoadAt = lflg ? ", load = LMEM" : ""
                |->SECTIONS {
                |-> 
    if lflg
                |->    .`arch`start : {
                |->        *(.start_vec)
                |->        *(.start)
                |->    } run = `lmemOrg`
                |-> 
                |->    GROUP(__code__) {
                |->        .text LOAD_START(__code_load__) {
                |->            __code_addr__ = .;
                |->            *(.start)
                |->            *(.text .text.*)
                |->            . = align(4);
                |->        }
                |->        .const : {
                |->            *(.rodata .rodata.* .constdata .constdata.*)
                |->            . = align(4);
                |->            __code_size__ = (. - __code_addr__ ) / 4;
                |->        }
                |->    } run = IMEM, load = LMEM
    else
                |->    .`arch`start : {
                |->        *(.intvec)
                |->    } run = `imemOrg`
                |-> 
                |->    GROUP(__code__) {
                |->        .text {
                |->            __code_addr__ = .;
                |->            *(.start)
                |->            *(.text .text.*)
                |->            . = align(4);
                |->        }
                |->        .const : {
                |->            *(.rodata .rodata.* .constdata .constdata.*)
                |->            . = align(4);
                |->        }
                |->    } run = IMEM
    end
                |->
    auto dmemLoad = lflg ? "LMEM" : "IMEM"
                |->    .data : LOAD_START(__data_load__) {
                |->        __data_addr__ = .;
                |->        *(.data .data.* .sdata .sdata.*)
                |->        . = align(4);
                |->        __data_size__ = (. - __data_addr__ ) / 4;
                |->    } run = `dmemOrg`, load = `dmemLoad`
                |->
                |->    .bss (NOLOAD): {
                |->        __bss_addr__ = .;
                |->        *(.bss .bss.*)
                |->        *(.sbss .sbss.*)
                |->        . = align(4);
                |->        __bss_size__ = (. - __bss_addr__ ) / 4;
                |->    } run = DMEM
                |-> 
    for sd in Utils.getSections()
                |->    `sd.sectid` : { *(`sd.sectid`) } run = `sd.memory`
    end
                |->
                |->    .symbols (NOLOAD): {
                |->        __boot_flag__ = 0;
    if !lflg
                |->        __code_load__ = ~0;
                |->        __code_size__ = ~0;
    end
                |->        __stack_top__ = `dmemOrg` + `dmemLen`;
                |->    }
                |->}
end


def genScript(sysFlag)
    Utils.setOptimize(BuildC.optimize)
    var ascpu: string = BuildC.cpu == "cortex-m0plus" ? "Cortex-M0+" : BuildC.cpu
    var bq: string = "`"
    var cincs: string[] = ^^em$props.get('em.build.CompileIncludes').split(';').concat(em$paths)^^
    var copts: string[] = ^^em$props.get('em.build.CompileOptions').split(';')^^
    var cpuopt: string = BuildC.arch == "arm" ? "cpu" : "arch"
    var echo: string = ^^em$props.get('em.build.CommandEcho') == 'true' ? '' : '@'^^
    var isWarmSrc: string = "<" + ^^em$props.get('em.lang.Builder').split('/')[0]^^ + "/is_warm.c>"
    var isWin: bool = ^^process.platform == 'win32'^^
    var ext: string = isWin ? ".exe" : ""
    var libarch: string = BuildC.cpu == "cortex-m0plus" ? "v6m_t_le_eabi" : BuildC.arch == "arm" ? "v6m_t_le_eabi" : BuildC.cpu
    var lobjs: string[] = ^^em$props.get('em.build.LinkerObjects').split(';')^^
    var srec: string = ^^em$find('em.build.misc/srec_cat.exe').replace(/\\/g, '/')^^
                |->TOOLS=`installDir`
                |->DIR=.
    if !sysFlag
                |->BOOTDIR=.em-boot/.out
    end
                |->CC=$TOOLS/bin/tiarmclang
                |->HEX=$TOOLS/bin/tiarmhex
                |->OBJDUMP=$TOOLS/bin/tiarmobjdump
    if !sysFlag
                |->SREC=`srec`
    end
                |->
                |->CFLAGS="\\
                |->`Utils.genDefines()`
                |->    --std=gnu++14 \\
                |->    -m`cpuopt`=`BuildC.cpu` \\
                |->    -ffunction-sections \\
                |->    -fdata-sections \\
                |->    -fomit-frame-pointer \\
                |->    -fno-exceptions \\
                |->    -fzero-initialized-in-bss \\
                |->    -nostdlib \\
                |->    -Wno-deprecated-register \\
                |->    -Wno-invalid-noreturn \\
                |->    -Wno-switch \\
                |->    -Wno-c99-designator \\
                |->    -Wno-c++20-designator \\
                |->"
                |->CINCS="\\
    for p in cincs
        p = ^^p.trim()^^
        continue if !p
                |->    -I`p` \\
    end
                |->    -I$TOOLS/include
                |->"
                |->COPTS="\\
    for o in copts
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
                |->LFLAGS="\\
                |->    -Wl,--entry_point=__em_program_start \\
                |->    -Wl,--display_error_number \\
                |->    -Wl,--diag_suppress=10068 \\
                |->    -Wl,--diag_suppress=10082 \\
                |->    -Wl,--diag_suppress=10334 \\
                |->    -Wl,--diag_suppress=10423 \\
                |->"
                |->LOBJS="\\
    for o in lobjs
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
                |->`genComp("main")`
end
    
def getTypeInfo()
    return typeInfo
end

def populate(buildDir, sysFlag)
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd.ld`^^, genLink(BuildC.bootLoader))
    ^^$Fs.writeFileSync^^(^^`${buildDir}/build.sh`^^, genScript(sysFlag))
    return if !BuildC.bootLoader
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd_boot.ld`^^, genLink(false))
end
