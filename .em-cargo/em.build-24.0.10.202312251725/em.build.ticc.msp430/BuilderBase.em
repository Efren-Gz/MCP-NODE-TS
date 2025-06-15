package em.build.ticc.msp430

from em.build.misc import ShellRunner
from em.build.misc import Utils

from em.lang import BuildC
from em.lang import BuilderI

module BuilderBase: BuilderI

private:

    config typeInfo: TypeInfo = {
        ARG:    [2, 2],
        CHAR:   [1, 1],
        INT:    [2, 1]
        INT8:   [1, 1],
        INT16:  [2, 2],
        INT32:  [4, 2],
        LONG:   [4, 2],
        PTR:    [2, 2],
        SHORT:  [2, 2],
        SIZE:   [2, 2],
    }

    template genScript(sysFlag: bool)

end

def em$configure()
    BuildC.compiler ?= "ticc"
end

def compile(buildDir)
    auto job = ShellRunner.exec(buildDir, "./build.sh")
    auto info = new <CompileInfo>
    info.procStat = job.status
    if info.procStat == 0
        var lines: string[] = ^^job.outlines.$elems.filter(s => s.match(/Grand Total:/))^^
        auto codeSz = 0
        auto rodataSz = 0
        auto rwdataSz = 0
        ^^let sep = ''^^
        for ln in lines
            ^^let words = ln.split(/\s+/)^^
            continue if ^^words.length != 5^^
            codeSz = ^^Number(words[2])^^
            rodataSz = ^^Number(words[3])^^
            rwdataSz = ^^Number(words[4])^^
        end
        info.imageSizes = ^^`image size: code (${codeSz}) + rodata (${rodataSz}) + rwdata (${rwdataSz})`^^
    else
        info.errMsgs = ^^['---- stderr ----\n', ...job.errlines.$elems, '---- stdout ----\n', ...job.outlines.$elems]^^
    end
    return info
end

def genScript(sysFlag)
    Utils.setOptimize(BuildC.optimize)
    var cincs: string[] = ^^em$props.get('em.build.CompileIncludes').split(';').concat(em$paths)^^
    var copts: string[] = ^^em$props.get('em.build.CompileOptions').split(';')^^
    var cpu: string = BuildC.cpu
    var cpudef: string = ^^cpu.toUpperCase()^^
    var lobjs: string[] = ^^em$props.get('em.build.LinkerObjects').split(';')^^
    var mdir: string = "T:/ti/ccs1230/ccs/ccs_base/msp430"
    var tdir: string = "T:/ti/ccs1230/ccs/tools/compiler/ti-cgt-msp430_21.6.1.LTS"
                |->TOOLS=`tdir`
                |->DIR=.
                |->                 
                |->CC=$TOOLS/bin/cl430
                |->LNK=$TOOLS/bin/lnk430
                |->HEX=$TOOLS/bin/hex430
                |-> 
                |->CFLAGS="\\
                |->`Utils.genDefines()`
                |->     -D__`cpudef`__ \\
                |->     -I$DIR \\
                |->     -k \\
                |->     --code_model=small \\
                |->     --data_model=small \\
##                |->     --opt_for_speed=4 \\
                |->     --use_hw_mpy=F5 \\
                |->     -vmspx \\
                |->"
                |->CINCS="\\
    for p in cincs
        p = ^^p.trim()^^
        continue if !p
                |->    -I`p` \\
    end
                |->    -I`mdir`/include
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
                |->     -c -x -w -q -u _c_int00 \\
                |->     -I`mdir`/include \\
                |->     `mdir`/include/lnk_`cpu`.cmd \\
                |->     -l `tdir`/lib/rts430x_sc_sd_eabi.lib
                |->"
                |->LOBJS="\\
    for o in lobjs
        o = ^^o.trim()^^
        continue if !o
                |->    `o` \\
    end
                |->"
                |-> 
                |->$CC $CINCS $CFLAGS $COPTS --c++14 $DIR/main.cpp -o $DIR/main.obj
                |->$LNK $LFLAGS -m $DIR/main.map -o $DIR/main.out $DIR/main.obj $LOBJS
                |->$HEX --ti_txt -o=main.out.txt main.out
                |->grep -F 'Grand Total:' $DIR/main.map
                |->sha256sum main.out.txt | cut -c -8 >main.out.sha32
end

def getTypeInfo()
    return typeInfo
end

def populate(buildDir, sysFlag)
###    ^^$Fs.writeFileSync^^(^^`${buildDir}/linkcmd.ld`^^, genLink(BuildC.bootLoader))
    ^^$Fs.writeFileSync^^(^^`${buildDir}/build.sh`^^, genScript(sysFlag))
end
