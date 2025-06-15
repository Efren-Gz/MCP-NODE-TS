package em.build.gcc

from em.lang import BuilderI
from em.lang import BuildC

from em.build.misc import ShellRunner
from em.build.misc import Utils

host module BuilderBase: BuilderI

    config ramAddr: addr_t
    config ramPage: uint32
    config ramSize: uint32
    config romAddr: addr_t
    config romSize: uint32
    config vecSize: uint32

    config gccFlav: string

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
    BuildC.compiler ?= "gcc"
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
                |->$CC -c $CFLAGS $CINCS $COPTS -o $DIR/`name`.obj $DIR/`name`.cpp
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
    auto romo = bflg ? ramAddr : romAddr
    auto roml = bflg && ramPage ? ramPage : romSize
    auto romOrg = <string>^^$sprintf("0x%08x", romo)^^
    auto romLen = <string>^^$sprintf("0x%08x", roml)^^
    #
    auto ramo = !bflg ? ramAddr : ramPage ? ramAddr + ramPage : ramAddr
    auto raml = !bflg ? ramSize : ramPage ? ramPage : ramSize
    auto ramOrg = <string>^^$sprintf("0x%08x", ramo)^^
    auto ramLen = <string>^^$sprintf("0x%08x", raml)^^
    #
    auto codeMem = bflg && !ramPage ? "RAM" : "ROM"
    auto arch = BuildC.arch

                |->MEMORY {
    if bflg
                |->    ABS : ORIGIN = 0x00001000, LENGTH = 0x10000000
    end
                |->    RAM : ORIGIN = `ramOrg`, LENGTH = `ramLen`
                |->    ROM : ORIGIN = `romOrg`, LENGTH = `romLen`
                |->}
                |->
                |->SECTIONS {
                |-> 
                |->     __boot_flag__ = `bflg ? 1 : 0`;
                |->     . = `romOrg`;
    if bflg
                |->
                |->    .desc : {
                |->        . += 16;
                |->        KEEP(*(.desc))
                |->    } > ABS
                |-> 
                |->    .boot : {
                |->        *(.boot.fxns)
                |->        . = ALIGN(., 4);
                |->        *(.boot.cfgs)
                |->        . = ALIGN(., 4);
                |->    } > ABS
                |-> 
    end
                |->     __code_load__ = .;
                |->
    if vecSize > 0
                |->    .`arch`start : AT(__code_load__) {
                |->        FILL(0xFF)
                |->        KEEP(*(.intvec))
        if !bflg
                |->        . = `vecSize`;
            if arch == "arm"
                |->        KEEP(*(.flashConfig))
            end
        end
                |->    } > `codeMem`
    end
                |-> 
    auto textLoad = vecSize == 0 && bflg ? "AT(__code_load__)" : ""
                |->    .text : `textLoad` {
                |->        *(.start)
                |->        *(.text .text.*)
                |->        *(.over*)
    if !bflg
                |->        *(.boot.fxns)
    end
                |->    } > `codeMem`
                |->
                |->    .const : {
                |->        *(.rodata .rodata.* .constdata .constdata.*)
    if !bflg
                |->        *(.boot.cfgs)
    end
                |->    } > `codeMem`
                |->    
                |->    __data_load_start__ = ALIGN(., 4);
                |->
    auto dataLoad = !bflg ? "AT(__data_load_start__)" : ramPage ? "AT(ALIGN(LOADADDR(.const) + SIZEOF(.const), 4))" : ""
                |->    .data : `dataLoad` {
                |->        *(.data .data.* .sdata .sdata.*)
                |->        . = ALIGN(., 4);
                |->    } > RAM
                |->
                |->    .bss (NOLOAD): {
                |->        *(.bss .bss.*)
                |->        *(.sbss .sbss.*)
                |->        . = ALIGN(., 4);
                |->    } > RAM
                |->
                |->    __bss_addr__ = ADDR(.bss);
                |->    __bss_size__ = SIZEOF(.bss) / 4;
                |->    __code_addr__ = `romOrg`;
                |->    __data_addr__ = ADDR(.data);
                |->    __data_load__ = LOADADDR(.data);
                |->    __data_size__ = SIZEOF(.data) / 4;
                |->    __global_pointer__ = __data_addr__ + 0x800;
                |->    __global_pointer$ = __global_pointer__;
                |->    __stack_top__ = `ramOrg` + `ramLen`;
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
    var tdir: string = ^^em$session.getToolsHome()^^ + "/gcc-" + BuildC.arch
                |->TOOLS=`tdir`
                |->DIR=.
    if !sysFlag
                |->BOOTDIR=.em-boot/.out
    end
                |->CC=$TOOLS/bin/`gccFlav`-gcc
                |->AS=$TOOLS/bin/`gccFlav`-as
                |->LD=$TOOLS/bin/`gccFlav`-ld
    switch BuildC.arch
    case "arm"
                |->LIBC=$TOOLS/`gccFlav`/lib/thumb/v6-m/nofp/libc_nano.a
    case "riscv32"
                |->LIBC=$TOOLS/`gccFlav`/lib/rv32i/ilp32/libc_nano.a
    end
                |->
                |->OBJCOPY=$TOOLS/bin/`gccFlav`-objcopy`ext`
                |->OBJDUMP=$TOOLS/bin/`gccFlav`-objdump`ext`
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
                |->    -nostdlib \\
                |->    -Wno-deprecated-register \\
                |->    -Wno-invalid-noreturn \\
                |->    -Wno-switch \\
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
    ^^$Fs.writeFileSync^^(^^`${buildDir}/build.sh`^^, genScript(sysFlag))
    return if !BuildC.bootLoader
    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd_boot.ld`^^, genLink(false))
end
