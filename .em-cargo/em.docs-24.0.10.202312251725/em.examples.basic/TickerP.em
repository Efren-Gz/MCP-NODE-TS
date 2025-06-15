package em.examples.basic

from em$distro import BoardC
from BoardC import AppLed
from BoardC import SysLed

from em.utils import FiberMgr
from em.utils import TickerMgr

module TickerP

private:

    function appTickCb: TickerMgr.TickCallback
    function sysTickCb: TickerMgr.TickCallback

    config appTicker: TickerMgr.Ticker&
    config sysTicker: TickerMgr.Ticker&

end

def em$construct()
    appTicker = TickerMgr.createH()
    sysTicker = TickerMgr.createH()
end

def em$run()
    appTicker.start(256, appTickCb)
    sysTicker.start(384, sysTickCb)
    FiberMgr.run()
end

def appTickCb()
    %%[c]
    AppLed.wink(100)
end

def sysTickCb()
    %%[d]
    SysLed.wink(100)
end
