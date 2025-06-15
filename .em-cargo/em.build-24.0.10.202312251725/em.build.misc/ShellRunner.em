package em.build.misc

host module ShellRunner

    type Job: struct
        status: int8
        errlines: string[]
        outlines: string[]
    end

    function exec(buildDir: string, cmd: string): Job&

end

def exec(buildDir, cmd)
    auto job = new <Job>
    ^^let proc = $ChildProc.spawnSync(cmd, {cwd: buildDir, shell: em$session.getShellPath()})^^
    job.status = ^^proc.status === null ? -1 : proc.status^^
    job.errlines = ^^String(proc.stderr).split('\n').map(s => s.trim())^^
    job.outlines = ^^String(proc.stdout).split('\n').map(s => s.trim())^^
    return job
end
