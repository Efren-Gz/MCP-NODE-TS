package em.build.misc

host module CopyLoader

    function writeScript(blddir: string, dstvol: string)

private:

    template genScript(blddir: string, dstvol: string)

end

def genScript(blddir, dstvol)
    auto shbang = "#! /bin/sh"
    ^^blddir = blddir.replace(/\\/g, '/')^^
|->>>
`shbang`
cp -f `blddir`/main.out.hex `dstvol`
|-<<<
end

def writeScript(blddir, dstvol)
    auto file = blddir + "/load.sh"
    ^^$Fs.writeFileSync^^(file, genScript(blddir, dstvol))
    ^^$Fs.chmodSync(file, 0o755)^^
end
