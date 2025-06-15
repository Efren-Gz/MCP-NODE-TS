package ti.distro.cc23xx

from em.utils import BoardMeta as BaseMeta

host module BoardMeta

    type DrvDesc: BaseMeta.DrvDesc

    type PinMap: struct
        appBut: int8
        appLed: int8
        appOut: int8
        extFlashCS: int8
        extFlashCLK: int8
        extFlashPICO: int8
        extFlashPOCI: int8
        sysDbgA: int8
        sysDbgB: int8
        sysDbgC: int8
        sysDbgD: int8
        sysLed: int8
    end

    type Record: struct
        activeLowLeds: bool
        baudRate: uint32
        clockFreq: uint32
        extFlashDisable: bool
        lfXtalEnable: bool
        pinMap: PinMap&
        drvDescs: DrvDesc&[]
    end

    config baseFileLoc: string = "ti.distro.cc23xx/em-boards"

    config attrNames: string[] = [
        "$inherits",
        "$overrides",
        "activeLowLeds",
        "baudRate",
        "clockFreq",
        "extFlashDisable",
        "lfXtalEnable",
    ]

    config pinNames: string[] = [
        "appBut",
        "appLed",
        "appOut",
        "extFlashCS",
        "extFlashCLK",
        "extFlashPICO",
        "extFlashPOCI",
        "sysDbgA",
        "sysDbgB",
        "sysDbgC",
        "sysDbgD",
        "sysLed",
    ] 

end