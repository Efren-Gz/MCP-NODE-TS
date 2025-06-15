package em.lang

host interface BuilderI

    type CompileInfo: struct
        errMsgs: string[]
        imageSizes: string
        procStat: int8
    end

    type TypeInfoDesc: uint8[2]

    type TypeInfo: struct
        ARG:    TypeInfoDesc
        CHAR:   TypeInfoDesc
        INT:    TypeInfoDesc
        INT8:   TypeInfoDesc
        INT16:  TypeInfoDesc
        INT32:  TypeInfoDesc
        LONG:   TypeInfoDesc
        PTR:    TypeInfoDesc
        SHORT:  TypeInfoDesc
        SIZE:   TypeInfoDesc
    end

    function compile(buildDir: string): CompileInfo&
    function getTypeInfo(): TypeInfo&
    function populate(buildDir: string, sysFlag: bool)

end
