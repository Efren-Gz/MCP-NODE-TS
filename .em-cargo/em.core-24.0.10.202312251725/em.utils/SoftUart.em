package em.utils

from em.hal import ConsoleUartI
from em.hal import GpioI
from em.hal import UsThreshI

from em.lang import Math

from em.mcu import Common

module SoftUart: ConsoleUartI

    proxy TxPin: GpioI
    proxy UsThresh: UsThreshI

private:

    config baudRate: uint32 = 115200
    config bitTime: uint16 = 7

end

def em$startup()
    TxPin.makeOutput()
    TxPin.set()
end

def setBaudH(rate)
    ## TODO -- implement
end

def flush()
end

def put(data)
    var bitCnt: uint8 = 10                              # Load Bit counter, 8data + ST/SP/SP
    var txByte: uint16 = (data << 1) | 0x600            # Add mark stop bits and space start bit
    var key: uarg_t = Common.GlobalInterrupts.disable()
    for ;;
        UsThresh.set(bitTime)
        if bitCnt-- == 0
            TxPin.set()
            break
        else
            if txByte & 0x01
                TxPin.set()
            else
                TxPin.clear()
            end
            txByte = txByte >> 1                        # shift next bit
        end
        UsThresh.pause()
    end
    Common.GlobalInterrupts.restore(key)
end
