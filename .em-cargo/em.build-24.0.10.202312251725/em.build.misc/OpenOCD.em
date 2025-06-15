package em.build.misc

host module OpenOCD

    config installDir: string
    template genLoad(cfgFile: string)
    template genLoad2(cfgFiles: string[], scriptDirs: string[])

end

def genLoad(cfgFile)
    var openocd: string = installDir + "/openocd.exe"
        |-> `openocd` -f `cfgFile` -c "program main.out.hex reset exit"
end

def genLoad2(scriptDirs, cfgFiles)
    var openocd: string = installDir + "/openocd.exe"
        |-> `openocd` \\
    for d in scriptDirs
        |->     -s `d` \\
    end
    for f in cfgFiles
        |->     -f `f` \\
    end
        |->     -c "program main.out.hex reset exit"
end
