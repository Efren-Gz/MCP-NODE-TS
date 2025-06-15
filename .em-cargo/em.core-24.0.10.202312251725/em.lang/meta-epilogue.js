
/* ---- BEGIN EPILOGUE ---- */

exports.$$exec = function() {
    let $$sealed = new Set;
    let $$uarr = Array.from($$units.values()).reverse();
    $$uarr.forEach(u => { if ('em$preconfigure' in u) u.em$preconfigure(); })
    $$uarr.forEach(u => { if ('em$configure' in u) u.em$configure(); })
    $$sealed = null;
    for (;;) {
        let k = 0;
        for (let u of $$uarr) {
            if ('$$used' in u) continue;
            if (u.em$used) {
                if ('em$uses__' in u) u.em$uses__();
                u.$$used = true;
                k++;
            }
        }
        if (k == 0) break;
    }
    $$uarr.forEach(u => { if (u.em$used && 'em$construct' in u) u.em$construct(); })
    let [pri, grps] = em$session.getTraceProps()
    $$uarr.forEach(u => { if (grps.has(u.em$traceGrp)) u.em$tracePri = pri })
}
