package ti.mcu.cc23xx

import GpioT {} as CS
import GpioT {} as CLK
import GpioT {} as PICO
import GpioT {} as POCI

from em.mcu import Common

module ExtFlashDisabler

    config CS_pin: int8
    config CLK_pin: int8
    config PICO_pin: int8
    config POCI_pin: int8

private:

    const SD_CMD: uint8 = 0xb9

end

def em$construct()
    CS.pin = CS_pin
    CLK.pin = CLK_pin
    PICO.pin = PICO_pin
    POCI.pin = POCI_pin
end

def em$startup()
    %%[c+]
    CS.makeOutput()
    CLK.makeOutput()
    PICO.makeOutput()
    POCI.makeInput()
    # attention
    CS.set()
    Common.BusyWait.wait(1)
    CS.clear()
    Common.BusyWait.wait(1)
    CS.set()
    Common.BusyWait.wait(50)
    # shutdown command
    CS.clear()
    for auto i = 0; i < 8; i++
        CLK.clear()
        if ((SD_CMD >> (7 - i)) & 0x01) == 0
            PICO.clear()
        else
            PICO.set()
        end
        CLK.set()
        Common.BusyWait.wait(1)
    end
    CLK.clear()
    CS.set()
    Common.BusyWait.wait(50)
    #
    CS.reset()
    CLK.reset()
    PICO.reset()
    POCI.reset()
    %%[c-]
end