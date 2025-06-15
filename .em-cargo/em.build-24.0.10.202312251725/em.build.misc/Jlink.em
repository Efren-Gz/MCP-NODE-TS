package em.build.misc

host module Jlink

    config installDir: string
    template genLoad(device: string, speed: uint16 = 4000)
    function genLoadScript(buildDir: string, device: string, speed: uint16 = 4000)

end

def genLoad(device, speed)
    auto suf = ^^process.platform^^ == "win32" ? ".exe" : "Exe"
    auto jlink = installDir + "/JLink" + suf
|->>>
JLINK=`jlink`
CMDS=jlink-cmds

echo halt > $CMDS
echo R >> $CMDS
echo loadfile main.out.hex >> $CMDS
echo go >> $CMDS
echo exit >> $CMDS

$JLINK -Device `device` -If SWD -Speed `speed` -AutoConnect 1 -CommandFile $CMDS  1> /dev/null
|-<<<
end

def genLoadScript(buildDir, device, speed)
    var sn: string = ^^`${buildDir}/load.sh`^^
    ^^$Fs.writeFileSync^^(sn, genLoad(device))
    ^^$Fs.chmodSync(sn, 0o755)^^
end
