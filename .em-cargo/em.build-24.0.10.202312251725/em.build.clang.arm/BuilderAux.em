package em.build.clang.arm

from em.lang import BuilderI

host module BuilderAux: BuilderI

private:

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

def compile(buildDir, progName, sha32)
    var gmake: string = ^^em$find('em.build.misc/gmake.exe').replace(/\\/g, '/')^^
    var prog: string = progName + ".out"
    ^^let proc = $ChildProc.spawnSync(gmake, [prog, `OTA_ROOT_SHA32=${sha32}`], {cwd: buildDir, shell: "C:\\git\\usr\\bin\\bash.exe"})^^
    var info: CompileInfo& = new<CompileInfo>
    info.errMsgs = ^^String(proc.stderr).split('\n').filter(s => s.match(/[[Ee]rror\[/))^^
    info.procStat = ^^proc.status === null ? -1 : proc.status^^
    if info.procStat == 0
        var lines: string[] = ^^String(proc.stdout).split('\n').map(s => s.trim()).filter(s => s.match(/bytes of/))^^
        info.imageSizes = "image size: "
        ^^let sep = ''^^
        for ln in lines
            ^^let words = ln.split(/\s+/)^^
            ^^let rw = (words[3] == 'readonly') ? 'RO' : 'RW'^^
            ^^let term = `${sep}${rw} ${words[4]} (${words[0].replace("'", ",")})`^^
            ^^sep = ' + '^^
            info.imageSizes += ^term
        end
    end
    return info
end

def getTypeInfo()
    return typeInfo
end

def populate(buildDir, sysFlag)
end
