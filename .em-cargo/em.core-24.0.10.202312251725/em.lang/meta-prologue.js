'use strict';

global.$$Agg = class $$Agg {
    constructor(cn) { 
        this.$$id = cn ? 0 : $$nxtId++
        this.$$cn = cn ? cn : `em$anon_${this.$$id}_S`
    }
    $$asn(o) {
        for (let p in o) {
            if (!$$assign(this[p], o[p])) this[p] = o[p]
        }
    }
}

global.$$Arr = class $$Arr {
    constructor(arr, cn, dv, dim) {
        this.$$elems = arr;
        this.$$id = cn ? 0 : $$nxtId++
        this.$$cn = cn ? cn : `em$anon_${this.$$id}_A`
        this.$$dv = dv;
        this.$$dim = dim
        if (!dim) return
        if (this.$$elems.length > dim) {
            this.$$elems.length = dim
        }
        else {
            this.length = dim
        }
    }
    get length() { return this.$$elems.length }
    set length(len) {
        for (let i = this.$$elems.length; i < len; i++) {
            let cn = `${this.$$cn}[${i}]`;
            this.$$elems[i] = this.$$dv(cn);
        }
    }

    get $elems() { return this.$$elems }
    $$asn(a) { 
        let src = a instanceof $$Arr ? a.$$elems : a;
        for (let i = 0; i < src.length; i++) {
            if (!$$assign(this.$$elems[i], src[i])) this.$$elems[i] = src[i]
        }
        this.$$elems.length = src.length;
        return this;
    }
    $$get(i) { return this.$$elems[i] }
    $$set(i, v) { this.length = i; return this.$$elems[i] = v }
}

global.$$Ref = class $$Ref {
    constructor(cn, fp) { 
        this.$$cn = cn
        this.$$fp = fp
    }
}

const $$sealed = new Set

global.$$alignof = function () {
    var al = 0
    for (var i = 0; i < arguments.length; i++) {
        var ti = arguments[i]
        if (ti[1] > al) al = ti[1]
    }
	return al
}

global.$$assign = function (dst, src) {
    let res = typeof dst == 'object' && '$$asn' in dst
    if (res) dst.$$asn(src)
    return res
}

global.$$sizeof = function () {
	var al = -1
	var sz = 0
	var d
    for (var i = 0; i < arguments.length; i++) {
        var ti = arguments[i]
		if (ti[1] > al) al = ti[1]
        if ((d = sz % ti[1]) != 0) sz += ti[1] - d
        sz += ti[0]
	}
    if ((d = sz % al) != 0) sz += al - d
    return sz
}


global.$$unsealed = function (path) {
    if ($$sealed.has(path)) return false;
    $$sealed.add(path);
    return true;
}

global.$$nxtId = exports.$$nxtId = 1
global.$$pr = null
global.$$ses = null
global.$$units = exports.$$units = new Map

exports.$$init = function(ses) {
        em$paths = ses.paths();
        em$props = ses.props;
        em$session = ses
        $$pr = ses.$EXPS.sprintf
        $$ses = ses
        $sprintf = ses.$EXPS.sprintf
        $Yaml = ses.$EXPS.Yaml
}
    
// for use within meta-module code escapes

global.$ChildProc = require('child_process')
global.$Fs = require('fs');
global.$Path = require('path');
global.$Yaml = null  // provided through Session
global.$sprintf = null // provided through Session

global.em$paths = [];
global.em$props = new Map;
global.em$session = null;

global.em$find = function(path) {
    for (const pp of em$paths) {
        let p = $Path.isAbsolute(path) ? path : $Path.normalize(`${pp}/${path}`)
        if ($Fs.existsSync(p)) return p 
    }
    return null
}

global.em$import = function(upath) {
    let u = $$ses.buildUnit(upath)
    if (!u) return undefined
    $$units.set(upath, require($$ses.mkOutFileFull(upath + '.js')));
    return $$units.get(upath)
}

global.em$renderSchema = function(name, appS, sysS) {
    return $$ses.genSchema(name, appS, sysS)
}

global.em__fail = function() {
    process.stderr.write('*** fail\n')
    process.exit(2)
}

global.em__halt = function() {
    process.stderr.write('*** halt\n')
    process.exit(1)
}

/* ---- END PROLOGUE ---- */

