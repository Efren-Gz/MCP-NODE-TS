package em.lang

module Atom

    config NULL_A: atom_t = @"<<null>>"
    config UNDEFINED_A: atom_t = @"<<undefined>>"

    function fromString(str: string, oatom: atom_t*): bool
    function hasTable(): bool
    function toString(atom: atom_t): string

private:

    const MASK: addr_t = 0x80000000

    config tableFlag: bool

end

def em$construct()
    tableFlag = ^^!!em$props.get(em$session.PROP_ATOM_TABLE)^^
end

def fromString(str, oatom)
    auto saddr = <addr_t>str
    return false if tableFlag || (saddr & MASK) == 0
    *oatom = <atom_t>saddr
    return true
end

def hasTable()
    return tableFlag
end

def toString(atom)
    return tableFlag ? ^^em$atoms[atom]^^ : <string>((<addr_t>atom) | MASK)
end