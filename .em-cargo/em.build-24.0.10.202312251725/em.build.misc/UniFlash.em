package em.build.misc

from em.lang import BuildC

host module UniFlash

    config installDir: string
    template genLoad(device: string)
    function genLoadScript(buildDir: string, device: string)

end

def genLoad(device)
    auto ext = ^^process.platform == 'win32'^^ ? ".bat" : ".sh"
    installDir = ^^em$session.getToolsHome()^^ + "/ti-uniflash" if !installDir
    auto tool = installDir + "/dslite" + ext
        |->`tool` -c `device`.ccxml main.out
end

def genLoadScript(buildDir, device)
    var sn: string = ^^`${buildDir}/load.sh`^^
    ^^$Fs.writeFileSync^^(sn, genLoad(device))
    ^^$Fs.chmodSync(sn, 0o755)^^
end
