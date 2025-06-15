package em.build.misc

from em.lang import BuildC

host module MSPFlasher

    template genLoad()

end

def genLoad()
    var tool: string = "C:/ti/MSPFlasher_1.3.20/MSP430Flasher"
        |->`tool` -i USB -j fast -e ERASE_MAIN -q -n `BuildC.cpu` -w main.out.txt -z [VCC] -g -s 1>&2
end
