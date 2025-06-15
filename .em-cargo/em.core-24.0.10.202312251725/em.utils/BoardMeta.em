package em.utils

host module BoardMeta

    type PinMap: struct
        pin: int8
    end

    type DrvDesc: struct
        name: string
        driver: string
        params: ptr_t
    end        

    type Record: struct
        attr: bool
        pinMap: PinMap&
        drvDescs: DrvDesc&[]
    end

    config baseFileLoc: string = "biz.biosbob.distro.axm0f343/em-boards"

    config attrNames: string[] = [
        "$inherits",
        "$overrides",
        "attr",
    ]

    config pinNames: string[] = [
        "pin",
    ] 

end