package em.build.segger2

from em.lang import BuilderI
from em.lang import BuildC

from em.build.misc import BuilderBaseI
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
    BuildC.compiler ?= "segger"
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
                |->$LD $LFLAGS -Map=`name`.map -T linkcmd`suf`.ld -o $DIR/`name`.out $DIR/`name`.obj $LOBJS $LIBC
                |->$OBJCOPY -O ihex `name`.out `name`.out.hex
                |->sha256sum `name`.out.hex | cut -c -8 >`name`.out.sha32
                |->$OBJCOPY -O binary `name`.out `name`.out.bin
                |->$OBJCOPY -O srec `name`.out `name`.out.srec
                |->$OBJCOPY -O verilog `name`.out `name`.out.vhex
                |->$OBJDUMP -h -d `name`.out >`name`.out.dis
                |->$OBJDUMP -h `name`.out
end

def genLink(bflg)
    #
    #
    auto arch = BuildC.arch
    auto lflg = BuildC.bootFlash
    auto dmemOrg = <string>^^$sprintf("0x%08x", dmemBase)^^
    auto dmemLen = <string>^^$sprintf("0x%08x", dmemSize)^^
    auto imemOrg = <string>^^$sprintf("0x%08x", imemBase)^^
    auto imemLen = <string>^^$sprintf("0x%08x", imemSize)^^
                |->MEMORY {
                |->    DMEM : ORIGIN = `dmemOrg`, LENGTH = `dmemLen`
                |->    IMEM : ORIGIN = `imemOrg`, LENGTH = `imemLen`
    if lflg
        auto lmemOrg = <string>^^$sprintf("0x%08x", lmemBase)^^
        auto lmemLen = <string>^^$sprintf("0x%08x", lmemSize)^^
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
    auto codeLoadAt = lflg ? "AT > LMEM" : ""
                |->SECTIONS {
                |-> 
                |->     __boot_flag__ = 0;
                |->
    if lflg
                |->    .`arch`start : {
                |->        KEEP(*(.start_vec))
                |->        KEEP(*(.start))
                |->    } > LMEM
                |-> 
                |->    .text : {
                |->         KEEP(*(.intvec))
                |->         *(.text .text.*)
                |->        . = ALIGN(., 4);
                |->    } > IMEM AT > LMEM
                |->
                |->    __const_load_start__ = (ALIGN(LOADADDR(.text) + SIZEOF(.text), 4));
                |->
                |->    .const : AT(__const_load_start__) {
                |->        *(.rodata .rodata.* .constdata .constdata.*)
                |->        . = ALIGN(., 4);
                |->    } > IMEM
                |-> 
                |->    __data_load_start__ = (ALIGN(LOADADDR(.const) + SIZEOF(.const), 4));
    else
                |->    .text : {
                |->         KEEP(*(.intvec))
                |->         *(.start)
                |->         *(.text .text.*)
                |->         . = ALIGN(., 4);
                |->    } > IMEM
                |-> 
                |->    .const : {
                |->        *(.rodata .rodata.* .constdata .constdata.*)
                |->        . = ALIGN(., 4);
                |->    } > IMEM
                |-> 
                |->    __data_load_start__ = ALIGN(., 4);
    end
                |->
                |->    .data : AT(__data_load_start__) {
                |->        *(.data .data.* .sdata .sdata.*)
                |->        . = ALIGN(., 4);
                |->    } > DMEM
                |->
                |->    .bss (NOLOAD): {
                |->        *(.bss .bss.*)
                |->        *(.sbss .sbss.*)
                |->        . = ALIGN(., 4);
                |->    } > DMEM
                |-> 
    for sd in Utils.getSections()
                |->    `sd.sectid` : { KEEP(*(`sd.sectid`)) } > `sd.memory`
    end
                |->
                |->    __bss_addr__ = ADDR(.bss);
                |->    __bss_size__ = SIZEOF(.bss) / 4;
                |->    __code_addr__ = ADDR(.text);
                |->    __data_addr__ = ADDR(.data);
                |->    __data_load__ = LOADADDR(.data);
                |->    __data_size__ = SIZEOF(.data) / 4;
    if lflg
                |->    __code_load__ = LOADADDR(.text);
                |->    __code_size__ = ((__data_load__ - __code_load__) / 4);
    else
                |->    __code_load__ = ~0;
                |->    __code_size__ = ~0;
    end
                |->    __global_pointer__ = __data_addr__ + 0x800;
                |->    __global_pointer$ = __global_pointer__;
                |->    __stack_top__ = `dmemOrg` + `dmemLen`;
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
    var gccflav: string =  BuildC.arch == "arm" ? "arm-none-eabi" : "riscv32-none-elf"
    var isWarmSrc: string = "<" + ^^em$props.get('em.lang.Builder').split('/')[0]^^ + "/is_warm.c>"
    var isWin: bool = ^^process.platform == 'win32'^^
    var ext: string = isWin ? ".exe" : ""
    var libarch: string = BuildC.cpu == "cortex-m0plus" ? "v6m_t_le_eabi" : BuildC.arch == "arm" ? "v6m_t_le_eabi" : BuildC.cpu
    var lobjs: string[] = ^^em$props.get('em.build.LinkerObjects').split(';')^^
    var srec: string = ^^em$find('em.build.misc/srec_cat.exe').replace(/\\/g, '/')^^
    var tdir: string = ^^em$session.getToolsHome()^^ + "/segger-" + (BuildC.arch == "arm" ? "arm" : "riscv")
                |->TOOLS=`tdir`
                |->DIR=.
    if !sysFlag
                |->BOOTDIR=.em-boot/.out
    end
                |->CC=$TOOLS/bin/segger-cc
    if isWin
                |->AS=$TOOLS/bin/cc
    else
                |->CPP=$TOOLS/llvm/bin/clang`ext`
                |->AS=$TOOLS/llvm/bin/clang`ext`
    end
                |->LD=$TOOLS/gcc/`gccflav`/bin/ld`ext`
                |->LIBC=$TOOLS/lib/libc_`libarch`_small.a
                |->
                |->OBJCOPY=$TOOLS/gcc/`gccflav`/bin/objcopy`ext`
                |->OBJDUMP=$TOOLS/gcc/`gccflav`/bin/objdump`ext`
    if !sysFlag
                |->SREC=`srec`
    end
                |->
                |->CFLAGS="\\
                |->`Utils.genDefines()`
                |->    --std=gnu++14 \\
    if BuildC.arch != "arm"
                |->    --target=`BuildC.arch` \\
    end
                |->    -m`cpuopt`=`BuildC.cpu` \\
                |->    -ffunction-sections \\
                |->    -fdata-sections \\
                |->    -fomit-frame-pointer \\
                |->    -fno-exceptions \\
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
                |->AFLAGS="\\
    if isWin
        if BuildC.arch == "riscv32"
                |->    -abi=ilp32 \\
        end
                |->    -clang \\
                |->    -`cpuopt`=`ascpu` \\
    else
                |->    -mno-relax \\
                |->    --target=`BuildC.arch` \\
    end
                |->"
                |->LFLAGS="\\
                |->    -e__em_program_start \\
                |->    -N \\
                |->    --gc-sections \\
                |->"
                |->LOBJS="\\
    for o in lobjs
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
    if sysFlag
                |->`genComp("boot")`
    else
                |->`genComp("main")`
        if BuildC.bootLoader
                |->buildTime=`bq`date +%s`bq`
                |->bootSha32=`bq`sha256sum $BOOTDIR/boot.out.hex | cut -c -8`bq`
                |->mainSha32=`bq`sha256sum main.out.hex | cut -c -8`bq`
                |->printf "0: CAFE0000%08x%s%s" $buildTime $bootSha32 $mainSha32 | xxd -r -g0 | $SREC - -binary -offset 0x1000 --out desc.hex -Intel
                |->$SREC main.out.hex -Intel -exclude 0x1000 0x1010 desc.hex -Intel -out main.out.ota -Intel -obs=16
                |->$SREC $BOOTDIR/boot.out.hex -Intel main.out.ota -Intel --out  main.out.hex -Intel -obs=16
                |->revSha=`bq`echo $bootSha32 | tac -rs .. | echo "$(tr -d '\n')"`bq`
                |->printf "{\\\"bootSha32\\\": \\\"$revSha\\\"}" >> main.out.ota
                |->cp $BOOTDIR/boot.out .
        end
    end
end
    
def getTypeInfo()
    return typeInfo
end

def populate(buildDir, sysFlag)
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd.ld`^^, genLink(BuildC.bootLoader))
    var sn: string = ^^`${buildDir}/build.sh`^^
    ^^$Fs.writeFileSync^^(sn, genScript(sysFlag))
    ^^$Fs.chmodSync(sn, 0o755)^^
    return if !BuildC.bootLoader
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd_boot.ld`^^, genLink(false))
end
