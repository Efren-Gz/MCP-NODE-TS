package em.utils

import AlarmMgr
import FiberMgr

module TickerMgr
            #   ^|
    type TickCallback: function()
            #   ^|
    type Ticker: opaque
            #   ^|
        host function initH()
            #   ^|
        function start(rate256: uint32, tickCb: TickCallback)
            #   ^|        
        function stop()
            #   ^|        
    end

    host function createH(): Ticker&
            #   ^|
private:

    def opaque Ticker
        alarm: AlarmMgr.Alarm&
        fiber: FiberMgr.Fiber&
        rate256: uint32
        tickCb: TickCallback
    end

    function alarmFB: FiberMgr.FiberBodyFxn

    var tickerTab: Ticker[]
    
end

def createH()
    var ticker: Ticker& = tickerTab[tickerTab.length++]
    ticker.initH()
    return ticker
end

def Ticker.initH()
    this.fiber = FiberMgr.createH(alarmFB, ^^this.$$cn^^)
    this.alarm = AlarmMgr.createH(this.fiber)
end

def alarmFB(arg)
    auto ticker = <Ticker&>arg
    return if ticker.tickCb == null
    ticker.tickCb() 
    ticker.alarm.wakeupAt(ticker.rate256)
end

def Ticker.start(rate256, tickCb)
    this.rate256 = rate256
    this.tickCb = tickCb
    this.alarm.wakeupAt(rate256)
end

def Ticker.stop()
    this.alarm.cancel()
    this.tickCb = null
end
