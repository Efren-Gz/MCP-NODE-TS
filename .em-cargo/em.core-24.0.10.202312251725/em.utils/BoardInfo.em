package em.utils

from em$distro import BoardMeta as Meta

host module BoardInfo

    const PROP_BOARD_CHAIN: string = "em.lang.BoardChain_"
    const PROP_BOARD_KIND: string = "em.lang.BoardKind"

    type PinMap: Meta.PinMap
    type DrvDesc: Meta.DrvDesc
    type Record: Meta.Record

    function getKind(): string
    function readRecordH(): Record&

private:

    function cacheGet(kind: string): Record&
    function cacheSet(kind: string, rec: Record&)

    function collapse(kind: string, db: ptr_t, set: ptr_t): ptr_t
    
    function init()

    function mergeBrd(baseBrd: ptr_t, extBrd: ptr_t)
    function mergeDb(baseDb: ptr_t, extDb: ptr_t)

    config baseFileLoc: string
    config localFileLoc: string

    config attrs: string[]
    config pins: string[]

    config boardKind: string

    var initFlg: bool
    var recCache: ptr_t

end

def cacheGet(kind)
    ^^if (!BoardInfo.recCache) BoardInfo.recCache = {}^^
    return ^^BoardInfo.recCache[kind]^^
end

def cacheSet(kind, rec)
    ^^BoardInfo.recCache[kind] = rec^^
end

def collapse(kind, db, set)
    return ^^db.$DEFAULTS^^ if ^^!kind || kind == '$DEFAULTS'^^
    var ext: ptr_t = ^^db[kind]^^
    if !ext
        printf "*** unknown board kind: '%s'\n", kind
        fail
    end
    if ^^set.has(kind)^^
        printf "*** circular inheritance chain: '%s'\n", kind
        fail
    end
    ^^set.add(kind)^^
    var base: ptr_t = collapse(^^ext.$inherits^^, db, set)
    mergeBrd(base, ext)
    return base
end

def getKind()
    init()
    return boardKind
end

def init()
    return if initFlg
    initFlg = true
    attrs = Meta.attrNames
    pins = Meta.pinNames
    baseFileLoc = Meta.baseFileLoc
    auto path = ^^$Path.join(em$session.getRootDir(), 'em-boards-local')^^
    localFileLoc = ^^$Fs.existsSync(path) ? path : null^^
    boardKind = ^^em$props.get^^(PROP_BOARD_KIND)
end

def mergeBrd(baseBrd, extBrd)
    ^^var aTab = []^^
    ^^for (a in extBrd) { aTab[a] = true; aTab.push(a) }^^
    for a in attrs
        ^^baseBrd[a] = extBrd[a]^^ if ^^a in extBrd^^
        ^^aTab[a] = false^^
    end
    for i: uint8 = 0; i < ^^aTab.length^^; i++
        var an: string = ^^aTab[i]^^
        if an != "pins" && an != "drvDescs" && an != "nvsFiles" && ^^aTab[an]^^
            printf "*** unknown attribute name: %s\n", an
            fail
        end
    end
    #
    ^^var pTab = []^^
    ^^for (p in extBrd.pins) { pTab[p] = true; pTab.push(p) }^^
    ^^baseBrd.pins = {}^^ if ^^!baseBrd.pins^^
    for p in pins
        ^^baseBrd.pins[p] = extBrd.pins[p]^^ if ^^extBrd.pins && p in extBrd.pins^^
        ^^pTab[p] = false^^
    end
    for i: uint8 = 0; i < ^^pTab.length^^; i++
        var pn: string = ^^pTab[i]^^
        continue if ^^pn[0] == '$'^^
        if ^^pTab[pn]^^
            printf "*** unknown pin name: %s\n", pn
            fail
        end
    end
    #
    ^^baseBrd.drvDescs = extBrd.drvDescs^^ if ^^extBrd.drvDescs^^
    ^^baseBrd.nvsFiles = extBrd.nvsFiles^^ if ^^extBrd.nvsFiles^^
end

def mergeDb(baseDb, extDb)
    ^^var brdSet = {}^^
    ^^var brdArr = []^^
    ^^for (b in baseDb) brdSet[b] = true^^
    ^^for (b in extDb) brdSet[b] = true^^
    ^^for (b in brdSet) brdArr.push(b)^^
    for i: uint8 = 0; i < ^^brdArr.length^^; i++
        ^^var brdKind = brdArr[i]^^
        ^^var baseBrd = baseDb[brdKind]^^
        ^^var extBrd = extDb[brdKind]^^
        if ^baseBrd && ^extBrd
            if ^^extBrd.$overrides^^
                mergeBrd(^baseBrd, ^extBrd)
            else
                printf "*** missing '$overrides' for %s\n", ^brdKind
                fail
            end
        elif ^extBrd
            if ^^extBrd.$overrides^^
                printf "*** no platform definition for '$overrides' for %s\n", ^brdKind
                fail
            else
                ^^baseDb[brdKind] = extDb[brdKind]^^
            end
        end
    end
end

def readRecordH()
    init()
    if boardKind == null
        printf "*** null board kind\n"
        fail
    end
    var rec: Record& = cacheGet(boardKind)
    return rec if rec
    var baseLoc: string = ^em$find(baseFileLoc)
    var baseDb: ptr_t = ^^$Yaml.load($Fs.readFileSync(baseLoc), 'utf-8')^^
    if localFileLoc != null
        var localDb: ptr_t = ^^$Yaml.load($Fs.readFileSync(localFileLoc), 'utf-8')^^
        mergeDb(baseDb, localDb)                    
    end
    var set: ptr_t = ^^new Set^^
    var base: ptr_t = collapse(boardKind, baseDb, set)
    var chain: ptr_t = ^^Array.from(set.values()).join('--')^^
    ^^em$props.set^^(PROP_BOARD_CHAIN, chain)
    rec = new <Record>
    rec.pinMap = new <PinMap>
    for a in attrs
        ^^rec[a] = base[a]^^
    end
    for p in pins
        ^^rec.pinMap[p] = base.pins[p]^^
    end
    ^^for (n in base.drvDescs) {^^
        ^^var o = base.drvDescs[n]^^
        rec.drvDescs[rec.drvDescs.length++] = new <DrvDesc> {
            name: ^n, driver: ^^o.driver^^, params: ^^o.params^^
        }
    ^^}^^
    cacheSet(boardKind, rec)
    return rec
end