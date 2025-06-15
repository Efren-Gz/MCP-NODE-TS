package em.utils

from em.hal import FlashI
from em.hal import FlashN

from em.lang import Assert
from em.mcu import Common
from em.lang import Console

import EpochTime
import Formatter
import HeapStatic

module Logger

    proxy Flash: FlashI

    type Accum: opaque
        function add(val: uint32 = 0)
        function clear()
        function getBin(idx: uint8): uint32
        function getCount(): uint32
        function getMax(): uint32
        function print()
    end

    type EventKind: opaque
        function cache(a1: addr_t = 0, a2: addr_t = 0, a3: addr_t = 0)
        function log(a1: addr_t = 0, a2: addr_t = 0, a3: addr_t = 0)
        function print(a1: addr_t = 0, a2: addr_t = 0, a3: addr_t = 0)
    end

    type Policy: enum
        NIL, QUIET, PRINT, STORE
    end

    config POLICY: Policy = Policy.NIL
    config ENTRY_COUNT: uint16 = 16
    config STORE_SECTOR: uint8 = 0

    host function createAccumH(lab: string, grp: string, lims: uint32[] = null): Accum&
    host function declareEventH(msg: string, grp: string): EventKind&

    function flush()
    function isEmpty(): bool
    function mkTime(): uint32
    function print()
    function putBytes(bp: uint8*, cnt: uint16)
    function putc(b: uint8)
    function store()

private:

    const PKT_CODE: uint8 = 0xFE
    const EVT_CODE: uint8 = 0xFD
    const ACC_CODE: uint8 = 0xFC
    const BEG_CODE: uint8 = 0xFB
    const END_CODE: uint8 = 0xFA

    type Group: class
        chars: char[4]
        host function initH(gs: string)
    end

    def opaque Accum
        data: uint32[]
        metaIdx: uint8
        function getMeta(): AccumMeta&
    end

    type AccumMeta: struct
        lab: string
        lims: uint32[]
        hasMax: bool
        limCnt: uint8
        group: Group
        size: uint8
    end

    def opaque EventKind
        msg: string
        kidx: uint16
        group: Group
    end

    type EventInst: class
        time: uint32
        a1: iarg_t
        a2: iarg_t
        a3: iarg_t
        kidx: uint16
        function put()
    end

    type Cursor: class
        idx: uint16
        function next(): EventInst&
    end

    config accMetaTab: AccumMeta[]

    config sectBeg: addr_t
    config sectEnd: addr_t

    config totalAccSize: uint16

    var accTab: Accum&[..]
    var evkTab: EventKind&[..]

    var buf: EventInst[]
    var curs: Cursor&

end

def em$configure()
    Flash ?= FlashN
end

def em$construct()
    buf = HeapStatic.allocH(sizeof<EventInst> * ENTRY_COUNT) if POLICY != Policy.NIL
    curs = HeapStatic.allocH(sizeof<Cursor>) if POLICY != Policy.NIL
    sectBeg = <addr_t>(Flash.getSectorSizeH() * STORE_SECTOR)
    sectEnd = sectBeg + Flash.getSectorSizeH()
 end

def createAccumH(lab, grp, lims)
    return null if POLICY == Policy.NIL
    auto accMeta = <AccumMeta&>accMetaTab[accMetaTab.length++]
    accMeta.lab = lab
    accMeta.group.initH(grp)
    accMeta.hasMax = (lims != null)
    accMeta.lims = lims if accMeta.hasMax
    accMeta.limCnt = <uint8>lims.length if accMeta.hasMax
    accMeta.size = (1 + (!accMeta.hasMax ? 0 : (1 + accMeta.limCnt))) * sizeof<uint32>
    auto acc = new<Accum>
    accTab[accTab.length++] = acc
    acc.data = HeapStatic.allocH(accMeta.size)
    acc.metaIdx = <uint8>accMetaTab.length
    totalAccSize += accMeta.size
    return acc
end

def declareEventH(msg, grp)
    return null if POLICY == Policy.NIL
    auto ek = new<EventKind>
    evkTab[evkTab.length++] = ek
    ek.kidx = evkTab.length
    ek.msg = <string>msg
    ek.group.initH(grp)
    return ek
end

def flush()
    print() if POLICY == Policy.PRINT
    store() if POLICY == Policy.QUIET || POLICY == Policy.STORE
end

def isEmpty()
    if POLICY != Policy.NIL
        for acc in accTab
            return false if acc.data[0]
        end
        for auto i = 0; i < ENTRY_COUNT; i++
            return false if buf[i].kidx != 0
        end
    end
    return true
end

def mkTime()
    var subs: uint32
    auto secs = EpochTime.getRaw(&subs)
    return (secs << 8) | (subs >> 24)
end

def print()
    if POLICY > Policy.QUIET
        putc(PKT_CODE)
        putc(BEG_CODE)
        for acc in accTab
            acc.print()
        end
        for auto i = 0; i < ENTRY_COUNT; i++
            auto evt = curs.next()
            continue if evt.kidx == 0
            evt.put()
        end
        putc(PKT_CODE)
        putc(END_CODE)
    end
end

def putBytes(bp, cnt)
    while cnt--
        auto b = *bp++
        putc(PKT_CODE) if b == PKT_CODE
        putc(b)
    end
end

def putc(b)
    Console.Provider.put(b)
end

def store()
    if POLICY != Policy.NIL && STORE_SECTOR > 0
        auto saddr = sectBeg
        Flash.erase(saddr)
        var et: uint32 = EpochTime.getCurrent()
        saddr = Flash.write(saddr, &et, sizeof<uint32>)
        for acc in accTab
            saddr = Flash.write(saddr, &acc.data[0], acc.getMeta().size)
        end
        for auto i = 0; i < ENTRY_COUNT; i++
            auto evt = curs.next()
            continue if evt.kidx == 0
            saddr = Flash.write(saddr, evt, sizeof<EventInst>)
            evt.kidx = 0
        end
    end
end

def Accum.add(val)
    auto accMeta = this.getMeta()
    this.data[0] += 1
    return if !accMeta.hasMax
    this.data[1] = val if val > this.data[1]
    for auto i = 0; i < accMeta.limCnt; i++
        this.data[2 + i] += 1 if val < accMeta.lims[i]
    end
end

def Accum.clear()
    auto accMeta = this.getMeta()
    auto words = accMeta.hasMax ? (2 + accMeta.limCnt) : 1
    ^memset(&this.data[0], 0, words * sizeof<uint32>)
end

def Accum.getBin(idx)
    return this.data[idx + 2]
end

def Accum.getCount()
    return this.data[0]
end

def Accum.getMax()
    return this.data[1]
end

def Accum.getMeta()
    return <AccumMeta&>(&accMetaTab[this.metaIdx-1])
end

def Accum.print()
    if POLICY > Policy.QUIET
        auto accMeta = this.getMeta()
        putc(PKT_CODE)
        putc(ACC_CODE)
        putc(this.metaIdx)
        putBytes(<uint8*>&this.data[0], accMeta.size)
    end
end

def Cursor.next()
    auto evt = &buf[this.idx++]
    this.idx = 0 if this.idx >= ENTRY_COUNT
    return evt
end

def EventInst.put()
    putc(PKT_CODE)
    putc(EVT_CODE)
    putBytes(<uint8*>this, sizeof<EventInst> - sizeof<uint16>)
end

def EventKind.cache(a1, a2, a3)
    if POLICY != Policy.NIL && ENTRY_COUNT > 0
        auto evt = curs.next()
        evt.time = mkTime()
        evt.kidx = this.kidx
        evt.a1 = <iarg_t>a1
        evt.a2 = <iarg_t>a2
        evt.a3 = <iarg_t>a3
    end
end

def EventKind.log(a1, a2, a3)
    this.cache(a1, a2, a3) if POLICY == Policy.STORE || POLICY == Policy.QUIET
    this.print(a1, a2, a3) if POLICY == Policy.PRINT
end

def EventKind.print(a1, a2, a3)
    if POLICY > Policy.QUIET
        var evt: EventInst
        evt.time = mkTime()
        evt.kidx = this.kidx
        evt.a1 = <iarg_t>a1
        evt.a2 = <iarg_t>a2
        evt.a3 = <iarg_t>a3
        evt.put()
    end
end

def Group.initH(gs)
    for auto i = 0; i < this.chars.length; i++
        this.chars[i] = ^^gs && gs[i] ? gs.charCodeAt(i) : " ".charCodeAt(0)^^
    end
end