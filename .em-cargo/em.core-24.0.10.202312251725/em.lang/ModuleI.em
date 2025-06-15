package em.lang

interface ModuleI

    type io32_t: uint32 volatile*

    host config em$exclude: bool
    host config em$export: bool
    host config em$traceGrp: string
    host config em$used: bool

    config em$tracePri: uint8

    host function em$configure()
    host function em$construct()
    template em$generateCode(prefix: string)

    function em$fail()
    function em$halt()
    function em$reset()
    function em$run()
    function em$shutdown()
    function em$startup()
    function em$startupDone()

    host function em$uses__()

end